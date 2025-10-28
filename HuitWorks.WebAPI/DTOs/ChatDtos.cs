using System;
using System.Collections.Generic;

namespace HuitWorks.WebAPI.DTOs
{
    public class ConversationDto
    {
        public string IdConversation { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public List<string> Members { get; set; } = new();
    }

    public class CreateConversationDto
    {
        public List<string> MemberIds { get; set; } = new();
    }

    public class MessageDto
    {
        public string IdMessage { get; set; } = null!;
        public string IdConversation { get; set; } = null!;
        public string IdSender { get; set; } = null!;
        public string? Content { get; set; }
        public string MessageType { get; set; } = "text";
        public string? FileUrl { get; set; }
        public string? FileName { get; set; }
        public long? FileSize { get; set; }
        public DateTime SentAt { get; set; }
        public int IsRead { get; set; }
    }

    public class SendMessageRequestDto
    {
        public string IdConversation { get; set; } = null!;
        public string IdSender { get; set; } = null!;
        public string? Content { get; set; }
        public string MessageType { get; set; } = "text";
        public string? FileUrl { get; set; }
        public string? FileName { get; set; }
        public long? FileSize { get; set; }
    }

    public class CompanyReviewDto
    {
        public string IdReview { get; set; } = null!;
        public string IdCompany { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateCompanyReviewDto
    {
        public string IdCompany { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }

    public class SupportTicketDto
    {
        public string IdTicket { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string Subject { get; set; } = null!;
        public string Message { get; set; } = null!;
        public string Status { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateSupportTicketDto
    {
        public string IdUser { get; set; } = null!;
        public string Subject { get; set; } = null!;
        public string Message { get; set; } = null!;
    }

    public class UpdateSupportTicketStatusDto
    {
        public string Status { get; set; } = null!; // open, in_progress, resolved, closed
    }
}


