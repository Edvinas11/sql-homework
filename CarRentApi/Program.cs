using Microsoft.AspNetCore.Mvc;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly string _connectionString;

    public OrdersController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")!;
    }

    [HttpPost("CreateOrderWithCars")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult CreateOrderWithCars([FromBody] CreateOrderDto orderDto)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            connection.Open();

            using var transaction = connection.BeginTransaction();

            try
            {
                using var orderCommand = new NpgsqlCommand(@"INSERT INTO ""Orders"" (""ClientId"", ""OrderDateStart"", ""OrderDateEnd"", ""Price"", ""Status"")
                                                            VALUES (@ClientId, @OrderDateStart, @OrderDateEnd, @Price, @Status)
                                                            RETURNING ""OrderId"";", connection, transaction);
            
                orderCommand.Parameters.AddWithValue("@ClientId", orderDto.ClientId);
                orderCommand.Parameters.AddWithValue("@OrderDateStart", NpgsqlTypes.NpgsqlDbType.Date, orderDto.OrderDateStart);
                orderCommand.Parameters.AddWithValue("@OrderDateEnd", orderDto.OrderDateEnd.HasValue ? (object)orderDto.OrderDateEnd.Value : DBNull.Value);
                orderCommand.Parameters.AddWithValue("@Price", NpgsqlTypes.NpgsqlDbType.Numeric, orderDto.Price);
                orderCommand.Parameters.AddWithValue("@Status", NpgsqlTypes.NpgsqlDbType.Text, orderDto.Status ?? "active");

                var orderId = (int)orderCommand.ExecuteScalar();

                foreach (var car in orderDto.Cars)
                {
                    using var carCommand = new NpgsqlCommand(@"INSERT INTO ""OrderCars"" (""OrderId"", ""CarId"", ""TotalPrice"")
                                                              VALUES (@OrderId, @CarId, @TotalPrice);", connection, transaction);

                    carCommand.Parameters.AddWithValue("@OrderId", orderId);
                    carCommand.Parameters.AddWithValue("@CarId", car.CarId);
                    carCommand.Parameters.AddWithValue("@TotalPrice", NpgsqlTypes.NpgsqlDbType.Numeric, car.TotalPrice);

                    carCommand.ExecuteNonQuery();
                }

                transaction.Commit();

                return CreatedAtAction(nameof(CreateOrderWithCars), new { orderId }, orderDto);
            }
            catch
            {
                transaction.Rollback();
                throw;
            }

        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }
    }
}

public class CreateOrderDto
{
    public int ClientId { get; set; }
    public DateTime OrderDateStart { get; set; }
    public DateTime? OrderDateEnd { get; set; }
    public decimal Price { get; set; }
    public string? Status { get; set; }
    public List<OrderCarDto> Cars { get; set; } = new();
}

public class OrderCarDto
{
    public int CarId { get; set; }
    public decimal TotalPrice { get; set; }
}