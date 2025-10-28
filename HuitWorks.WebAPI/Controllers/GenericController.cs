using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GenericController<TEntity> : ControllerBase where TEntity : class
    {
        private readonly JobConnectDbContext _context;
        public GenericController(JobConnectDbContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var list = await _context.Set<TEntity>().ToListAsync();
                return Ok(list);
            }
            catch (Exception ex)
            {
                // Log ex if logger is available
                return StatusCode(500, new { error = "An unexpected error occurred while retrieving data.", detail = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var entity = await _context.Set<TEntity>().FindAsync(id);
                if (entity == null)
                    return NotFound(new { error = $"{typeof(TEntity).Name} with id '{id}' not found." });

                return Ok(entity);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An unexpected error occurred while retrieving the entity.", detail = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] TEntity entity)
        {
            try
            {
                _context.Set<TEntity>().Add(entity);
                await _context.SaveChangesAsync();
                return CreatedAtAction(
                    nameof(GetById),
                    new { id = GetKey(entity) },
                    entity);
            }
            catch (DbUpdateException dbEx)
            {
                return BadRequest(new { error = "Database update error during create.", detail = dbEx.InnerException?.Message ?? dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An unexpected error occurred while creating the entity.", detail = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] TEntity entity)
        {
            try
            {
                var key = GetKey(entity);
                if (key != id)
                    return BadRequest(new { error = "The id in the URL does not match the entity id." });

                _context.Entry(entity).State = EntityState.Modified;
                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (DbUpdateConcurrencyException concEx)
            {
                return Conflict(new { error = "Concurrency conflict occurred while updating.", detail = concEx.Message });
            }
            catch (DbUpdateException dbEx)
            {
                return BadRequest(new { error = "Database update error during update.", detail = dbEx.InnerException?.Message ?? dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An unexpected error occurred while updating the entity.", detail = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var entity = await _context.Set<TEntity>().FindAsync(id);
                if (entity == null)
                    return NotFound(new { error = $"{typeof(TEntity).Name} with id '{id}' not found." });

                _context.Set<TEntity>().Remove(entity);
                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (DbUpdateException dbEx)
            {
                return BadRequest(new { error = "Database update error during delete.", detail = dbEx.InnerException?.Message ?? dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "An unexpected error occurred while deleting the entity.", detail = ex.Message });
            }
        }

        private string GetKey(TEntity entity)
        {
            #pragma warning disable CS8602 
            var keyName = _context.Model
                .FindEntityType(typeof(TEntity))
                .FindPrimaryKey()
                .Properties
                .Select(p => p.Name)
                .Single();
            #pragma warning restore CS8602

            var keyValue = entity.GetType()
                .GetProperty(keyName)
                ?.GetValue(entity);

            return keyValue?.ToString() ?? string.Empty;
        }
    }
}
