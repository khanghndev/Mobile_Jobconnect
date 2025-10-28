// File: Program.cs
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using HuitWorks.WebAPI.Data;
using FirebaseAdmin; // Đảm bảo namespace này đúng
using Google.Apis.Auth.OAuth2; // Đảm bảo namespace này đúng
using HuitWorks.WebAPI.Services; // THÊM DÒNG NÀY: để sử dụng IGeocodingService và NominatimGeocodingService
using HuitWorks.WebAPI.Hubs;

var builder = WebApplication.CreateBuilder(args);
// Đọc cấu hình từ appsettings.json
builder.Configuration.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

// Cấu hình Controllers và NewtonsoftJson cho việc xử lý vòng lặp tham chiếu
builder.Services.AddControllers()
   .AddNewtonsoftJson(opts =>
      opts.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore);
builder.Services.AddSignalR();

// Cấu hình DbContext
builder.Services.AddDbContext<JobConnectDbContext>(options =>
   options.UseMySql(
      builder.Configuration.GetConnectionString("DefaultConnection"),
      new MySqlServerVersion(new Version(8, 0, 0)) // Đảm bảo phiên bản MySQL Server của bạn
   )
);

// Khởi tạo Firebase Admin SDK
// Đảm bảo file "serviceAccountKey.json" nằm đúng đường dẫn và được copy vào output directory
string firebaseKeyPath = Path.Combine(builder.Environment.ContentRootPath, "serviceAccountKey.json");
if (File.Exists(firebaseKeyPath))
{
    FirebaseApp.Create(new AppOptions
    {
        Credential = GoogleCredential.FromFile(firebaseKeyPath)
    });
}
else
{
    // Log hoặc xử lý lỗi nếu không tìm thấy file key
    Console.WriteLine("Firebase serviceAccountKey.json not found. Firebase Admin SDK will not be initialized.");
}


// Cấu hình JWT Authentication
var jwtConfig = builder.Configuration.GetSection("JwtSettings");
var keyBytes = Encoding.UTF8.GetBytes(jwtConfig["Key"]!); // Sử dụng null-forgiving operator `!` nếu bạn chắc chắn "Key" luôn tồn tại

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtConfig["Issuer"],
        ValidAudience = jwtConfig["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(keyBytes)
    };
    // Cho phép SignalR nhận JWT qua query string (trên WebSocket)
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) && (path.StartsWithSegments("/hubs/chat") || path.StartsWithSegments("/chathub")))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});

// Cấu hình Authorization
builder.Services.AddAuthorization();

// Cấu hình CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        // Cho WebSocket + Cookie/Auth (SignalR) hoạt động với nhiều origin
        policy
            .SetIsOriginAllowed(_ => true)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// THÊM DÒNG NÀY ĐỂ ĐĂNG KÝ GEOCODING SERVICE
// Đăng ký IGeocodingService và HttpClient được quản lý cho NominatimGeocodingService
builder.Services.AddHttpClient<IGeocodingService, NominatimGeocodingService>();

// Đăng ký Spatial Query Service
builder.Services.AddScoped<ISpatialQueryService, SpatialQueryService>();

// Đăng ký Appwrite Spatial Service (for future Appwrite integration)
builder.Services.AddScoped<IAppwriteSpatialService, AppwriteSpatialService>();

// Đăng ký Job Recommendation Service
builder.Services.AddScoped<IJobRecommendationService, JobRecommendationService>();

// Đăng ký CV Render Service
builder.Services.AddScoped<ICvRenderService, CvRenderService>();

// Đăng ký CV Template Seed Service
builder.Services.AddScoped<ICvTemplateSeedService, CvTemplateSeedService>();


// Cấu hình Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "HuitWorks API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Nhập 'Bearer {token}' vào ô này",
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
   {
      {
         new OpenApiSecurityScheme
         {
            Reference = new OpenApiReference
            {
               Type = ReferenceType.SecurityScheme,
               Id = "Bearer"
            }
         },
         Array.Empty<string>() // Hoặc new List<string>()
      }
   });
});

var app = builder.Build();

// Cấu hình HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage(); // Hiển thị trang lỗi chi tiết trong môi trường development
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "HuitWorks API v1"));
}
else
{
    // Trong môi trường production, bạn có thể muốn có một error handler tùy chỉnh
    // app.UseExceptionHandler("/Error");
    // app.UseHsts(); // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
}

app.UseHttpsRedirection(); // Chuyển hướng HTTP sang HTTPS
app.UseCors("AllowAll"); // Áp dụng chính sách CORS (duy nhất)

app.UseAuthentication(); // Kích hoạt middleware xác thực
app.UseAuthorization();  // Kích hoạt middleware phân quyền

// Phục vụ static files (để truy cập các file PDF đã export trong /wwwroot/uploads/cv)
app.UseStaticFiles();

app.MapControllers();    // Map các route đến controllers
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<ChatHub>("/chathub");

app.Run();