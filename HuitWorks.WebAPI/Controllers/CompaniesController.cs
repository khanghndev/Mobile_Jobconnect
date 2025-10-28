// --- CompaniesController.cs ---
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MySqlConnector;

[ApiController]
[Route("api/[controller]")]
public class CompaniesController : ControllerBase
{
    private readonly JobConnectDbContext _context;
    public CompaniesController(JobConnectDbContext context) => _context = context;

    // GET: api/companies
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CompanyDto>>> GetAll()
    {
        var list = await _context.Companies
            .Select(c => new CompanyDto
            {
                IdCompany = c.IdCompany,
                CompanyName = c.CompanyName,
                TaxCode = c.TaxCode,
                Address = c.Address,
                Description = c.Description,
                LogoCompany = c.LogoCompany,
                WebsiteUrl = c.WebsiteUrl,
                Scale = c.Scale,
                Industry = c.Industry,
                BusinessLicenseUrl = c.BusinessLicenseUrl,
                Status = c.Status,
                IsFeatured = c.IsFeatured,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            })
            .ToListAsync();

        return Ok(list);
    }

    // GET: api/companies/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<CompanyDto>> GetById(string id)
    {
        var dto = await _context.Companies
            .Where(c => c.IdCompany == id)
            .Select(c => new CompanyDto
            {
                IdCompany = c.IdCompany,
                CompanyName = c.CompanyName,
                TaxCode = c.TaxCode,
                Address = c.Address,
                Description = c.Description,
                LogoCompany = c.LogoCompany,
                WebsiteUrl = c.WebsiteUrl,
                Scale = c.Scale,
                Industry = c.Industry,
                BusinessLicenseUrl = c.BusinessLicenseUrl,
                Status = c.Status,
                IsFeatured = c.IsFeatured,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            })
            .FirstOrDefaultAsync();

        if (dto == null)
            return NotFound(new { message = "Không tìm thấy công ty." });

        return Ok(dto);
    }

    // GET: api/companies/featured
    [HttpGet("featured")]
    public async Task<ActionResult<IEnumerable<CompanyDto>>> GetFeatured()
    {
        var list = await _context.Companies
            .Where(c => c.IsFeatured == 1)
            .Select(c => new CompanyDto
            {
                IdCompany = c.IdCompany,
                CompanyName = c.CompanyName,
                TaxCode = c.TaxCode,
                Address = c.Address,
                Description = c.Description,
                LogoCompany = c.LogoCompany,
                WebsiteUrl = c.WebsiteUrl,
                Scale = c.Scale,
                Industry = c.Industry,
                BusinessLicenseUrl = c.BusinessLicenseUrl,
                Status = c.Status,
                IsFeatured = c.IsFeatured,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            })
            .ToListAsync();

        return Ok(list);
    }

    // POST: api/companies
    [HttpPost]
    public async Task<ActionResult<CompanyDto>> Create([FromBody] CreateCompanyDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        if (await _context.Companies.AnyAsync(c => c.TaxCode == dto.TaxCode))
            return Conflict(new { message = $"Mã số thuế '{dto.TaxCode}' đã tồn tại." });

        var now = DateTime.UtcNow;
        var entity = new Company
        {
            IdCompany = Guid.NewGuid().ToString(),
            CompanyName = dto.CompanyName,
            TaxCode = dto.TaxCode,
            Address = dto.Address,
            Description = dto.Description,
            LogoCompany = dto.LogoCompany,
            WebsiteUrl = dto.WebsiteUrl,
            Scale = dto.Scale,
            Industry = dto.Industry,
            BusinessLicenseUrl = dto.BusinessLicenseUrl,
            Status = dto.Status,
            IsFeatured = dto.IsFeatured,
            CreatedAt = now,
            UpdatedAt = now
        };

        _context.Companies.Add(entity);
        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException ex)
            when (ex.InnerException is MySqlException mysqlEx && mysqlEx.Number == 1062)
        {
            return Conflict(new { message = "Duplicate key error – mã số thuế đã tồn tại." });
        }

        var result = new CompanyDto
        {
            IdCompany = entity.IdCompany,
            CompanyName = entity.CompanyName,
            TaxCode = entity.TaxCode,
            Address = entity.Address,
            Description = entity.Description,
            LogoCompany = entity.LogoCompany,
            WebsiteUrl = entity.WebsiteUrl,
            Scale = entity.Scale,
            Industry = entity.Industry,
            BusinessLicenseUrl = entity.BusinessLicenseUrl,
            Status = entity.Status,
            IsFeatured = entity.IsFeatured,
            CreatedAt = entity.CreatedAt,
            UpdatedAt = entity.UpdatedAt
        };

        return CreatedAtAction(nameof(GetById), new { id = result.IdCompany }, result);
    }

    // PUT: api/companies/{id}
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] UpdateCompanyDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var entity = await _context.Companies.FindAsync(id);
        if (entity == null)
            return NotFound(new { message = "Không tìm thấy công ty." });

        entity.CompanyName = dto.CompanyName ?? entity.CompanyName;
        entity.TaxCode = dto.TaxCode ?? entity.TaxCode;
        entity.Address = dto.Address ?? entity.Address;
        entity.Description = dto.Description ?? entity.Description;
        entity.LogoCompany = dto.LogoCompany ?? entity.LogoCompany;
        entity.WebsiteUrl = dto.WebsiteUrl ?? entity.WebsiteUrl;
        entity.Scale = dto.Scale ?? entity.Scale;
        entity.Industry = dto.Industry ?? entity.Industry;
        entity.BusinessLicenseUrl = dto.BusinessLicenseUrl ?? entity.BusinessLicenseUrl;
        entity.Status = dto.Status ?? entity.Status;
        entity.IsFeatured = dto.IsFeatured ?? entity.IsFeatured;
        entity.UpdatedAt = DateTime.UtcNow;

        _context.Companies.Update(entity);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/companies/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        var entity = await _context.Companies.FindAsync(id);
        if (entity == null)
            return NotFound(new { message = "Không tìm thấy công ty." });

        _context.Companies.Remove(entity);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
