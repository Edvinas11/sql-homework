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

                var orderId = (int)orderCommand.ExecuteScalar()!;

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

    [HttpGet("SearchOrdersByClient")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult SearchOrdersByClient([FromQuery] string name, [FromQuery] string lastname)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            connection.Open();

            using var command = new NpgsqlCommand(@"SELECT ord.""OrderId"", ord.""ClientId"", ord.""OrderDateStart"", ord.""OrderDateEnd"", ord.""Price"", ord.""Status"", 
                                                         cli.""Name"", cli.""Lastname"" 
                                                  FROM ""Orders"" ord 
                                                  INNER JOIN ""Clients"" cli ON ord.""ClientId"" = cli.""Id""
                                                  WHERE cli.""Name"" ILIKE @Name AND cli.""Lastname"" ILIKE @Lastname;", connection);

            command.Parameters.AddWithValue("@Name", $"%{name}%");
            command.Parameters.AddWithValue("@Lastname", $"%{lastname}%");

            using var reader = command.ExecuteReader();
            var orders = new List<object>();

            while (reader.Read())
            {
                orders.Add(new
                {
                    OrderId = reader["OrderId"],
                    ClientId = reader["ClientId"],
                    OrderDateStart = reader["OrderDateStart"],
                    OrderDateEnd = reader["OrderDateEnd"],
                    Price = reader["Price"],
                    Status = reader["Status"],
                    ClientName = reader["Name"],
                    ClientLastname = reader["Lastname"]
                });
            }

            return Ok(orders);
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }
    }

    [HttpPut("UpdateOrderWithCars/{orderId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult UpdateOrderWithCars(int orderId, [FromBody] UpdateOrderWithCarsDto orderDto)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            connection.Open();

            using var transaction = connection.BeginTransaction();

            try
            {
                // Update the Orders table
                using var updateOrderCommand = new NpgsqlCommand(@"UPDATE ""Orders"" 
                                                                 SET ""OrderDateStart"" = @OrderDateStart, 
                                                                     ""OrderDateEnd"" = @OrderDateEnd, 
                                                                     ""Price"" = @Price, 
                                                                     ""Status"" = @Status
                                                                 WHERE ""OrderId"" = @OrderId;", connection, transaction);

                updateOrderCommand.Parameters.AddWithValue("@OrderId", orderId);
                updateOrderCommand.Parameters.AddWithValue("@OrderDateStart", NpgsqlTypes.NpgsqlDbType.Date, orderDto.OrderDateStart);
                updateOrderCommand.Parameters.AddWithValue("@OrderDateEnd", orderDto.OrderDateEnd.HasValue ? (object)orderDto.OrderDateEnd.Value : DBNull.Value);
                updateOrderCommand.Parameters.AddWithValue("@Price", NpgsqlTypes.NpgsqlDbType.Numeric, orderDto.Price);
                updateOrderCommand.Parameters.AddWithValue("@Status", NpgsqlTypes.NpgsqlDbType.Text, orderDto.Status);

                int rowsAffected = updateOrderCommand.ExecuteNonQuery();

                if (rowsAffected == 0)
                {
                    transaction.Rollback();
                    return NotFound(new { Message = "Order not found", OrderId = orderId });
                }

                // Delete existing cars for the order
                using var deleteCarsCommand = new NpgsqlCommand(@"DELETE FROM ""OrderCars"" WHERE ""OrderId"" = @OrderId;", connection, transaction);
                deleteCarsCommand.Parameters.AddWithValue("@OrderId", orderId);
                deleteCarsCommand.ExecuteNonQuery();

                // Insert updated cars
                foreach (var car in orderDto.Cars)
                {
                    using var insertCarCommand = new NpgsqlCommand(@"INSERT INTO ""OrderCars"" (""OrderId"", ""CarId"", ""TotalPrice"")
                                                                    VALUES (@OrderId, @CarId, @TotalPrice);", connection, transaction);

                    insertCarCommand.Parameters.AddWithValue("@OrderId", orderId);
                    insertCarCommand.Parameters.AddWithValue("@CarId", car.CarId);
                    insertCarCommand.Parameters.AddWithValue("@TotalPrice", NpgsqlTypes.NpgsqlDbType.Numeric, car.TotalPrice);

                    insertCarCommand.ExecuteNonQuery();
                }

                transaction.Commit();
                return Ok(new { Message = "Order and cars updated successfully", OrderId = orderId });
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

    [HttpDelete("DeleteOrder/{orderId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult DeleteOrder(int orderId)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            connection.Open();

            using var deleteOrderCommand = new NpgsqlCommand(@"DELETE FROM ""Orders"" WHERE ""OrderId"" = @OrderId;", connection);
            deleteOrderCommand.Parameters.AddWithValue("@OrderId", orderId);

            int rowsAffected = deleteOrderCommand.ExecuteNonQuery();

            if (rowsAffected == 0)
            {
                return NotFound(new { Message = "Order not found", OrderId = orderId });
            }

            return Ok(new { Message = "Order deleted successfully", OrderId = orderId });
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

public class UpdateOrderWithCarsDto
{
    public DateTime OrderDateStart { get; set; }
    public DateTime? OrderDateEnd { get; set; }
    public decimal Price { get; set; }
    public string Status { get; set; }
    public List<OrderCarDto> Cars { get; set; } = new();
}