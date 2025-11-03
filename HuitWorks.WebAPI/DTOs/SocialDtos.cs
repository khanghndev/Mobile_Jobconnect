using System;
using System.Collections.Generic;

namespace HuitWorks.WebAPI.DTOs
{
    public class SocialPostDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? AvatarUrl { get; set; }
        public string? IdGroup { get; set; }
        public string? GroupName { get; set; }
        public string Content { get; set; } = null!;
        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public string Visibility { get; set; } = "public";
        public string PostType { get; set; } = "post";
        public List<string> Hashtags { get; set; } = new List<string>();
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int LikesCount { get; set; }
        public int CommentsCount { get; set; }
        public int SharesCount { get; set; }
        public bool IsSaved { get; set; }
        public Dictionary<string, int> ReactionsSummary { get; set; } = new Dictionary<string, int>();
        public string? CurrentUserReaction { get; set; }
    }

    public class CreateSocialPostDto
    {
        public string IdUser { get; set; } = null!;
        public string? IdGroup { get; set; }
        public string Content { get; set; } = null!;
        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public string Visibility { get; set; } = "public";
        public string PostType { get; set; } = "post";
        public List<string>? Hashtags { get; set; }
    }

    public class UpdateSocialPostDto
    {
        public string Content { get; set; } = null!;
        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public string Visibility { get; set; } = "public";
        public string PostType { get; set; } = "post";
        public List<string>? Hashtags { get; set; }
    }

    public class SocialCommentDto
    {
        public string IdComment { get; set; } = null!;
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? ParentComment { get; set; }
        public string Content { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsEdited { get; set; }
        public int LikesCount { get; set; }
        public int RepliesCount { get; set; }
        public string? UserName { get; set; }
        public string? AvatarUrl { get; set; }
        public bool IsLiked { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
    }

    public class CreateSocialCommentDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? ParentComment { get; set; }
        public string Content { get; set; } = null!;
    }

    public class UpdateSocialCommentDto
    {
        public string IdUser { get; set; } = null!;
        public string Content { get; set; } = null!;
    }

    public class LikeCommentDto
    {
        public string IdUser { get; set; } = null!;
    }

    public class ReportCommentDto
    {
        public string ReporterId { get; set; } = null!;
        public string Reason { get; set; } = null!;
    }

    public class SocialConnectionDto
    {
        public string IdUser1 { get; set; } = null!;
        public string IdUser2 { get; set; } = null!;
        public string Status { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateConnectionRequestDto
    {
        public string FromUserId { get; set; } = null!;
        public string ToUserId { get; set; } = null!;
    }

    public class AcceptAllRequestsDto
    {
        public string UserId { get; set; } = null!;
    }

    public class CancelAllSentDto
    {
        public string UserId { get; set; } = null!;
    }

    public class SocialMessageDto
    {
        public string IdMessage { get; set; } = null!;
        public string SenderId { get; set; } = null!;
        public string ReceiverId { get; set; } = null!;
        public string Content { get; set; } = null!;
        public int IsRead { get; set; }
        public DateTime SentAt { get; set; }
    }

    public class SendMessageDto
    {
        public string SenderId { get; set; } = null!;
        public string ReceiverId { get; set; } = null!;
        public string Content { get; set; } = null!;
    }

    // ==================== REACTIONS DTOs ====================
    public class SocialReactionDto
    {
        public string IdReaction { get; set; } = null!;
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? AvatarUrl { get; set; }
        public string ReactionType { get; set; } = "like";
        public DateTime CreatedAt { get; set; }
    }

    public class CreateReactionDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string ReactionType { get; set; } = "like";
    }

    public class ReactionSummaryDto
    {
        public string ReactionType { get; set; } = null!;
        public int Count { get; set; }
        public List<string> UserIds { get; set; } = new List<string>();
    }

    // ==================== SHARES DTOs ====================
    public class SocialShareDto
    {
        public string IdShare { get; set; } = null!;
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? AvatarUrl { get; set; }
        public string ShareType { get; set; } = "public";
        public string? SharedWithGroup { get; set; }
        public string? GroupName { get; set; }
        public DateTime SharedAt { get; set; }
    }

    public class CreateShareDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string ShareType { get; set; } = "public";
        public string? SharedWithGroup { get; set; }
    }

    // ==================== SAVED POSTS DTOs ====================
    public class SavedPostDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public DateTime SavedAt { get; set; }
        public string FolderName { get; set; } = "All Posts";
        public string? Note { get; set; }
        public SocialPostDto? Post { get; set; }
    }

    public class CreateSavedPostDto
    {
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? FolderName { get; set; }
        public string? Note { get; set; }
    }

    public class UpdateSavedPostDto
    {
        public string? FolderName { get; set; }
        public string? Note { get; set; }
    }

    // ==================== FOLLOW DTOs ====================
    public class SocialFollowDto
    {
        public string FollowerId { get; set; } = null!;
        public string FollowingId { get; set; } = null!;
        public string? FollowerName { get; set; }
        public string? FollowerAvatar { get; set; }
        public string? FollowingName { get; set; }
        public string? FollowingAvatar { get; set; }
        public string FollowType { get; set; } = "normal";
        public DateTime CreatedAt { get; set; }
    }

    public class CreateFollowDto
    {
        public string FollowerId { get; set; } = null!;
        public string FollowingId { get; set; } = null!;
        public string FollowType { get; set; } = "normal";
    }

    public class FollowStatsDto
    {
        public int FollowersCount { get; set; }
        public int FollowingCount { get; set; }
        public bool IsFollowing { get; set; }
        public bool IsFollowedBy { get; set; }
    }

    // ==================== REACTION DTOs ====================
    public class ReactToPostDto
    {
        public string PostId { get; set; } = null!;
        public string UserId { get; set; } = null!;
        public string ReactionType { get; set; } = null!;
    }

    public class PostReactionsDto
    {
        public string PostId { get; set; } = null!;
        public Dictionary<string, int> ReactionsByType { get; set; } = new Dictionary<string, int>();
        public string? CurrentUserReaction { get; set; }
        public int TotalReactions { get; set; }
    }
}


