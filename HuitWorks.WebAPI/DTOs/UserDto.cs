// DTOs/UserDTOs.cs
using HuitWorks.WebAPI.Models;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.DTOs
{
    public class UserDto
    {
        public string? IdUser { get; set; } = null!;
        public string? UserName { get; set; } = null!;
        public string? Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string? Password { get; set; }
        public string? IdRole { get; set; } = null!;
        public string? AccountStatus { get; set; }
        public string? AvatarUrl { get; set; }
        public string? SocialLogin { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public Role Role { get; set; } = null!;
    }
    public class CreateUserDto
    {
        public string IdUser { get; set; } = null!;
        public string UserName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string? Password { get; set; }
        public string IdRole { get; set; } = null!;
        public string AccountStatus { get; set; } = null!;
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? AvatarUrl { get; set; }
        public string? SocialLogin { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
    public class UpdateUserDto
    {
        public string? UserName { get; set; } = null!;
        public string? Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string? Password { get; set; }
        public string? AccountStatus { get; set; }
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? AvatarUrl { get; set; }
        public string? SocialLogin { get; set; }
        public DateTime? UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
