using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Data
{
    public class JobConnectDbContext : DbContext
    {
        public JobConnectDbContext(DbContextOptions<JobConnectDbContext> options) : base(options) { }

        public DbSet<Role> Roles { get; set; }
        public DbSet<Company> Companies { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<CandidateInfo> CandidateInfo { get; set; }
        public DbSet<RecruiterInfo> RecruiterInfo { get; set; }
        public DbSet<JobPosting> JobPostings { get; set; }
        public DbSet<JobApplication> JobApplications { get; set; }
        public DbSet<Resume> Resumes { get; set; }
        public DbSet<ResumeSkill> ResumeSkills { get; set; }
        public DbSet<Website> Websites { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<SubscriptionPackage> SubscriptionPackages { get; set; }
        public DbSet<JobTransaction> JobTransactions { get; set; }
        public DbSet<InterviewSchedule> InterviewSchedules { get; set; }
        public DbSet<SavedResume> SavedResumes { get; set; }
        public DbSet<News> News { get; set; }
        public DbSet<JobSaved> JobSaveds { get; set; }
        public DbSet<JobTransactionDetail> JobTransactionDetails { get; set; }
        public DbSet<SaveCandidate> SaveCandidates { get; set; }
        public DbSet<UserActivityLog> UserActivityLogs { get; set; } = null!;
        public DbSet<ReportType> ReportTypes { get; set; } = null!;
        public DbSet<Report> Reports { get; set; } = null!;
        public DbSet<JobPostUsageLog> JobPostUsageLogs { get; set; }
        public DbSet<CvViewUsageLog> CvViewUsageLogs { get; set; }
        public DbSet<SocialPost> SocialPosts { get; set; }
        public DbSet<SocialComment> SocialComments { get; set; }
        public DbSet<SocialCommentLike> SocialCommentLikes { get; set; }
        public DbSet<SocialCommentReport> SocialCommentReports { get; set; }
        public DbSet<SocialReaction> SocialReactions { get; set; }
        public DbSet<SocialShare> SocialShares { get; set; }
        public DbSet<SavedPost> SavedPosts { get; set; }
        public DbSet<SocialFollow> SocialFollows { get; set; }
        public DbSet<SocialConnection> SocialConnections { get; set; }
        public DbSet<SocialMessage> SocialMessages { get; set; }
        public DbSet<Hashtag> Hashtags { get; set; }
        public DbSet<SocialPostHashtag> SocialPostHashtags { get; set; }
        public DbSet<Conversation> Conversations { get; set; }
        public DbSet<ConversationMember> ConversationMembers { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<CompanyReview> CompanyReviews { get; set; }
        public DbSet<SupportTicket> SupportTickets { get; set; }
        public DbSet<CandidateSkills> CandidateSkills { get; set; }
        public DbSet<CandidateAvailability> CandidateAvailability { get; set; }
        public DbSet<CandidateProjects> CandidateProjects { get; set; }

        // CV Builder entities
        public DbSet<CvTemplate> CvTemplates { get; set; }
        public DbSet<CvDocument> CvDocuments { get; set; }
        public DbSet<CvExport> CvExports { get; set; }
        public DbSet<CvShareLink> CvShareLinks { get; set; }

        // Social Groups
        public DbSet<SocialGroup> SocialGroups { get; set; }
        public DbSet<GroupMember> GroupMembers { get; set; }
        public DbSet<GroupPost> GroupPosts { get; set; }
        public DbSet<GroupComment> GroupComments { get; set; }
        public DbSet<GroupReaction> GroupReactions { get; set; }
        public DbSet<GroupTag> GroupTags { get; set; }

        public DbSet<OtpCode> OtpCodes { get; set; }

        public DbSet<DeviceToken> DeviceTokens { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Primary keys
            modelBuilder.Entity<Role>().HasKey(r => r.IdRole);
            modelBuilder.Entity<Company>().HasKey(c => c.IdCompany);
            modelBuilder.Entity<User>().HasKey(u => u.IdUser);
            modelBuilder.Entity<CandidateInfo>().HasKey(ci => ci.IdUser);
            modelBuilder.Entity<RecruiterInfo>().HasKey(ri => ri.IdUser);
            modelBuilder.Entity<JobPosting>().HasKey(jp => jp.IdJobPost);
            modelBuilder.Entity<JobApplication>().HasKey(ja => new { ja.IdJobPost, ja.IdUser });
            modelBuilder.Entity<Resume>().HasKey(r => r.IdResume);
            modelBuilder.Entity<ResumeSkill>().HasKey(rs => new { rs.IdResume, rs.Skill });
            modelBuilder.Entity<Website>().HasKey(w => w.IdWebsite);
            modelBuilder.Entity<Notification>().HasKey(n => n.IdNotification);
            modelBuilder.Entity<SubscriptionPackage>().HasKey(p => p.IdPackage);
            modelBuilder.Entity<JobTransaction>().HasKey(t => t.IdTransaction);
            modelBuilder.Entity<InterviewSchedule>().HasKey(s => s.IdSchedule);
            modelBuilder.Entity<SavedResume>().HasKey(sr => sr.IdSave);
            modelBuilder.Entity<News>().HasKey(n => n.IdNews);
            modelBuilder.Entity<News>().Property(n => n.IdNews).ValueGeneratedOnAdd();
            modelBuilder.Entity<JobSaved>().HasKey(js => new { js.IdJobPost, js.IdUser });
            modelBuilder.Entity<JobTransactionDetail>().HasKey(jt => jt.IdTransaction);
            modelBuilder.Entity<SaveCandidate>().HasKey(sc => new { sc.IdUserRecruiter, sc.IdUserCandidate });
            // Social entities
            modelBuilder.Entity<SocialPost>().HasKey(p => p.IdPost);
            modelBuilder.Entity<SocialComment>().HasKey(c => c.IdComment);
            modelBuilder.Entity<SocialReaction>().HasKey(r => r.IdReaction);
            modelBuilder.Entity<SocialShare>().HasKey(s => s.IdShare);
            modelBuilder.Entity<SavedPost>().HasKey(sp => new { sp.IdPost, sp.IdUser });
            modelBuilder.Entity<SocialFollow>().HasKey(sf => new { sf.FollowerId, sf.FollowingId });
            modelBuilder.Entity<SocialConnection>().HasKey(sc => new { sc.IdUser1, sc.IdUser2 });
            modelBuilder.Entity<SocialMessage>().HasKey(m => m.IdMessage);
            modelBuilder.Entity<Hashtag>().HasKey(h => h.IdHashtag);
            modelBuilder.Entity<SocialPostHashtag>().HasKey(ph => new { ph.IdPost, ph.IdHashtag });

            modelBuilder.Entity<Hashtag>()
                .HasIndex(h => h.Slug)
                .IsUnique()
                .HasDatabaseName("uq_hashtag_slug");

            modelBuilder.Entity<SocialComment>()
                .HasOne(c => c.Post)
                .WithMany()
                .HasForeignKey(c => c.IdPost)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialComment>()
                .HasOne(c => c.Parent)
                .WithMany(c => c.Replies)
                .HasForeignKey(c => c.ParentComment)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialComment>()
                .HasOne(c => c.User)
                .WithMany()
                .HasForeignKey(c => c.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            // SocialCommentLikes configuration
            modelBuilder.Entity<SocialCommentLike>()
                .HasOne(cl => cl.Comment)
                .WithMany(c => c.Likes)
                .HasForeignKey(cl => cl.IdComment)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialCommentLike>()
                .HasOne(cl => cl.User)
                .WithMany()
                .HasForeignKey(cl => cl.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialCommentLike>()
                .HasIndex(cl => new { cl.IdComment, cl.IdUser })
                .IsUnique();

            // SocialCommentReports configuration
            modelBuilder.Entity<SocialCommentReport>()
                .HasOne(cr => cr.Comment)
                .WithMany(c => c.Reports)
                .HasForeignKey(cr => cr.IdComment)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialCommentReport>()
                .HasOne(cr => cr.Reporter)
                .WithMany()
                .HasForeignKey(cr => cr.ReporterId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialCommentReport>()
                .HasOne(cr => cr.Reviewer)
                .WithMany()
                .HasForeignKey(cr => cr.ReviewedBy)
                .OnDelete(DeleteBehavior.SetNull);


            modelBuilder.Entity<SocialConnection>()
                .HasOne(sc => sc.User1)
                .WithMany()
                .HasForeignKey(sc => sc.IdUser1)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialConnection>()
                .HasOne(sc => sc.User2)
                .WithMany()
                .HasForeignKey(sc => sc.IdUser2)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialMessage>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialMessage>()
                .HasOne(m => m.Receiver)
                .WithMany()
                .HasForeignKey(m => m.ReceiverId)
                .OnDelete(DeleteBehavior.Cascade);

            // Social Reactions
            modelBuilder.Entity<SocialReaction>()
                .HasOne(r => r.Post)
                .WithMany()
                .HasForeignKey(r => r.IdPost)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialReaction>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialReaction>()
                .HasIndex(r => new { r.IdPost, r.IdUser })
                .IsUnique();

            // Social Shares
            modelBuilder.Entity<SocialShare>()
                .HasOne(s => s.Post)
                .WithMany()
                .HasForeignKey(s => s.IdPost)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialShare>()
                .HasOne(s => s.User)
                .WithMany()
                .HasForeignKey(s => s.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialShare>()
                .HasOne(s => s.Group)
                .WithMany()
                .HasForeignKey(s => s.SharedWithGroup)
                .OnDelete(DeleteBehavior.SetNull);

            // Saved Posts
            modelBuilder.Entity<SavedPost>()
                .HasOne(sp => sp.Post)
                .WithMany()
                .HasForeignKey(sp => sp.IdPost)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SavedPost>()
                .HasOne(sp => sp.User)
                .WithMany()
                .HasForeignKey(sp => sp.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            // Social Follow
            modelBuilder.Entity<SocialFollow>()
                .HasOne(sf => sf.Follower)
                .WithMany()
                .HasForeignKey(sf => sf.FollowerId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SocialFollow>()
                .HasOne(sf => sf.Following)
                .WithMany()
                .HasForeignKey(sf => sf.FollowingId)
                .OnDelete(DeleteBehavior.Cascade);

            // Chat
            modelBuilder.Entity<Conversation>().HasKey(c => c.IdConversation);
            modelBuilder.Entity<ConversationMember>().HasKey(cm => new { cm.IdConversation, cm.IdUser });
            modelBuilder.Entity<Message>().HasKey(m => m.IdMessage);
            modelBuilder.Entity<Message>()
                .HasOne(m => m.Conversation)
                .WithMany()
                .HasForeignKey(m => m.IdConversation)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Message>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.IdSender)
                .OnDelete(DeleteBehavior.Cascade);

            // Company review
            modelBuilder.Entity<CompanyReview>().HasKey(r => r.IdReview);

            // Support ticket
            modelBuilder.Entity<SupportTicket>().HasKey(t => t.IdTicket);

            // Candidate profile tables
            modelBuilder.Entity<CandidateSkills>().HasKey(cs => cs.IdSkill);
            modelBuilder.Entity<CandidateSkills>()
                .HasOne(cs => cs.User)
                .WithMany()
                .HasForeignKey(cs => cs.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CandidateAvailability>().HasKey(ca => ca.IdAvailability);
            modelBuilder.Entity<CandidateAvailability>()
                .HasOne(ca => ca.User)
                .WithMany()
                .HasForeignKey(ca => ca.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CandidateProjects>().HasKey(cp => cp.IdProject);
            modelBuilder.Entity<CandidateProjects>()
                .HasOne(cp => cp.User)
                .WithMany()
                .HasForeignKey(cp => cp.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            // Social Groups configuration
            modelBuilder.Entity<SocialGroup>().HasKey(g => g.IdGroup);
            modelBuilder.Entity<GroupMember>().HasKey(gm => new { gm.IdGroup, gm.IdUser });
            modelBuilder.Entity<GroupPost>().HasKey(gp => gp.IdPost);
            modelBuilder.Entity<GroupComment>().HasKey(gc => gc.IdComment);
            modelBuilder.Entity<GroupReaction>().HasKey(gr => gr.IdReaction);
            modelBuilder.Entity<GroupTag>().HasKey(gt => new { gt.IdGroup, gt.TagName });

            // Social Group relationships
            modelBuilder.Entity<SocialGroup>()
                .HasOne(g => g.Creator)
                .WithMany()
                .HasForeignKey(g => g.CreatedBy)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupMember>()
                .HasOne(gm => gm.SocialGroup)
                .WithMany(g => g.GroupMembers)
                .HasForeignKey(gm => gm.IdGroup)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupMember>()
                .HasOne(gm => gm.User)
                .WithMany()
                .HasForeignKey(gm => gm.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupPost>()
                .HasOne(gp => gp.SocialGroup)
                .WithMany(g => g.GroupPosts)
                .HasForeignKey(gp => gp.IdGroup)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupPost>()
                .HasOne(gp => gp.User)
                .WithMany()
                .HasForeignKey(gp => gp.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupPost>()
                .HasOne(gp => gp.Approver)
                .WithMany()
                .HasForeignKey(gp => gp.ApprovedBy)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<GroupComment>()
                .HasOne(gc => gc.GroupPost)
                .WithMany(gp => gp.GroupComments)
                .HasForeignKey(gc => gc.IdPost)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupComment>()
                .HasOne(gc => gc.User)
                .WithMany()
                .HasForeignKey(gc => gc.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupComment>()
                .HasOne(gc => gc.ParentComment)
                .WithMany(gc => gc.Replies)
                .HasForeignKey(gc => gc.ParentId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupReaction>()
                .HasOne(gr => gr.User)
                .WithMany()
                .HasForeignKey(gr => gr.IdUser)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupTag>()
                .HasOne(gt => gt.SocialGroup)
                .WithMany(g => g.GroupTags)
                .HasForeignKey(gt => gt.IdGroup)
                .OnDelete(DeleteBehavior.Cascade);

            // Unique constraint for reactions
            modelBuilder.Entity<GroupReaction>()
                .HasIndex(gr => new { gr.EntityType, gr.EntityId, gr.IdUser })
                .IsUnique();

            // CV Builder entities configuration
            modelBuilder.Entity<CvTemplate>().HasKey(ct => ct.IdTemplate);
            modelBuilder.Entity<CvTemplate>()
                .Property(ct => ct.IdTemplate)
                .HasMaxLength(64)
                .IsRequired();
            modelBuilder.Entity<CvTemplate>()
                .HasIndex(ct => ct.Slug)
                .IsUnique();

            modelBuilder.Entity<CvDocument>().HasKey(cd => cd.IdDocument);
            modelBuilder.Entity<CvDocument>()
                .Property(cd => cd.IdDocument)
                .HasMaxLength(64)
                .IsRequired();
            modelBuilder.Entity<CvDocument>()
                .HasOne(cd => cd.User)
                .WithMany()
                .HasForeignKey(cd => cd.IdUser)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<CvDocument>()
                .HasOne(cd => cd.Template)
                .WithMany(ct => ct.CvDocuments)
                .HasForeignKey(cd => cd.IdTemplate)
                .OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<CvDocument>()
                .HasIndex(cd => cd.IdUser)
                .HasDatabaseName("idx_cvdoc_user");
            modelBuilder.Entity<CvDocument>()
                .HasIndex(cd => cd.IdTemplate)
                .HasDatabaseName("idx_cvdoc_template");

            modelBuilder.Entity<CvExport>().HasKey(ce => ce.IdExport);
            modelBuilder.Entity<CvExport>()
                .Property(ce => ce.IdExport)
                .HasMaxLength(64)
                .IsRequired();
            modelBuilder.Entity<CvExport>()
                .HasOne(ce => ce.Document)
                .WithMany(cd => cd.CvExports)
                .HasForeignKey(ce => ce.IdDocument)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<CvExport>()
                .HasIndex(ce => ce.IdDocument)
                .HasDatabaseName("idx_cvexport_doc");
            modelBuilder.Entity<CvExport>()
                .HasIndex(ce => ce.CreatedAt)
                .HasDatabaseName("idx_cvexport_time");

            modelBuilder.Entity<CvShareLink>().HasKey(csl => csl.IdShare);
            modelBuilder.Entity<CvShareLink>()
                .Property(csl => csl.IdShare)
                .HasMaxLength(64)
                .IsRequired();
            modelBuilder.Entity<CvShareLink>()
                .HasIndex(csl => csl.Token)
                .IsUnique();
            modelBuilder.Entity<CvShareLink>()
                .HasOne(csl => csl.Document)
                .WithMany(cd => cd.CvShareLinks)
                .HasForeignKey(csl => csl.IdDocument)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<CvShareLink>()
                .HasIndex(csl => csl.IdDocument)
                .HasDatabaseName("idx_cvshare_doc");
            modelBuilder.Entity<CvShareLink>()
                .HasIndex(csl => csl.ExpireAt)
                .HasDatabaseName("idx_cvshare_exp");
            modelBuilder.Entity<UserActivityLog>(entity =>
            {
                entity.ToTable("userActivityLog");
                entity.HasKey(u => u.IdLog);
                entity.Property(u => u.IdLog).HasColumnName("idLog").HasMaxLength(64).IsRequired();
                entity.Property(u => u.IdUser).HasColumnName("idUser").HasMaxLength(64).IsRequired();
                entity.Property(u => u.ActionType).HasColumnName("actionType").HasMaxLength(100).IsRequired();
                entity.Property(u => u.Description).HasColumnName("description").HasColumnType("TEXT");
                entity.Property(u => u.EntityName).HasColumnName("entityName").HasMaxLength(100);
                entity.Property(u => u.EntityId).HasColumnName("entityId").HasMaxLength(64);
                entity.Property(u => u.IpAddress).HasColumnName("ipAddress").HasMaxLength(45);
                entity.Property(u => u.UserAgent).HasColumnName("userAgent").HasMaxLength(255);
                entity.Property(u => u.CreatedAt).HasColumnName("createdAt").HasDefaultValueSql("CURRENT_TIMESTAMP").IsRequired();
                entity.HasOne(u => u.User).WithMany().HasForeignKey(u => u.IdUser).OnDelete(DeleteBehavior.Cascade).HasConstraintName("fk_userActivityLog_user");
                entity.HasIndex(u => u.IdUser).HasDatabaseName("idx_userActivityLog_user");
                entity.HasIndex(u => u.ActionType).HasDatabaseName("idx_userActivityLog_action");
            });
            modelBuilder.Entity<ReportType>().HasKey(rt => rt.ReportTypeId);
            modelBuilder.Entity<Report>().HasKey(r => r.ReportId);
            modelBuilder.Entity<Report>().HasOne(r => r.ReportType).WithMany().HasForeignKey(r => r.ReportTypeId).OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<Report>().HasOne(r => r.User).WithMany().HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<JobPostUsageLog>(entity =>
            {
                entity.ToTable("JobPostUsageLog");
                entity.HasKey(j => j.IdLog);
                entity.Property(j => j.IdLog).HasColumnName("idLog").HasMaxLength(64).IsRequired();
                entity.Property(j => j.IdTransaction).HasColumnName("idTransaction").HasMaxLength(50).IsRequired();
                entity.Property(j => j.IdJobPost).HasColumnName("idJobPost").HasMaxLength(64).IsRequired(false); // Cho phép null (ON DELETE SET NULL)
                entity.Property(j => j.UsedAt).HasColumnName("usedAt").HasDefaultValueSql("CURRENT_TIMESTAMP").IsRequired();
                entity.HasOne(j => j.JobTransaction).WithMany().HasForeignKey(j => j.IdTransaction).OnDelete(DeleteBehavior.Cascade).HasConstraintName("fk_JobPostUsageLog_Transaction");
                entity.HasOne(j => j.JobPosting).WithMany().HasForeignKey(j => j.IdJobPost).OnDelete(DeleteBehavior.SetNull).HasConstraintName("fk_JobPostUsageLog_JobPost");
                entity.HasIndex(j => j.IdTransaction).HasDatabaseName("idx_JobPostUsageLog_transaction");
                entity.HasIndex(j => j.IdJobPost).HasDatabaseName("idx_JobPostUsageLog_jobPost");
            });
            modelBuilder.Entity<CvViewUsageLog>(entity =>
            {
                entity.ToTable("CvViewUsageLog");
                entity.HasKey(c => c.IdLog);
                entity.Property(c => c.IdLog).HasColumnName("idLog").HasMaxLength(64).IsRequired();
                entity.Property(c => c.IdTransaction).HasColumnName("idTransaction").HasMaxLength(50).IsRequired();
                entity.Property(c => c.IdResume).HasColumnName("idResume").HasMaxLength(64).IsRequired(false);
                entity.Property(c => c.UsedAt).HasColumnName("usedAt").HasDefaultValueSql("CURRENT_TIMESTAMP").IsRequired();
                entity.HasOne(c => c.JobTransaction).WithMany().HasForeignKey(c => c.IdTransaction).OnDelete(DeleteBehavior.Cascade).HasConstraintName("fk_CvViewUsageLog_Transaction");
                entity.HasOne(c => c.Resume).WithMany().HasForeignKey(c => c.IdResume).OnDelete(DeleteBehavior.SetNull).HasConstraintName("fk_CvViewUsageLog_Resume");
                entity.HasIndex(c => c.IdTransaction).HasDatabaseName("idx_CvViewUsageLog_transaction");
                entity.HasIndex(c => c.IdResume).HasDatabaseName("idx_CvViewUsageLog_resume");
            });
        }
    }
}
