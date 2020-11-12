using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Gateway01.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private readonly IHttpClientFactory _httpClientFactory; 

        private readonly ILogger<WeatherForecastController> _logger;

        private static JsonSerializerOptions options = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };

        private string _host = "localhost";
        private int _port = 5002;
        private string _uri = "WeatherForecast";

        public WeatherForecastController(ILogger<WeatherForecastController> logger, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;

            _httpClientFactory = httpClientFactory;  

            if (Environment.GetEnvironmentVariable("BACKEND_HOST") != null) {
                _host = Environment.GetEnvironmentVariable("BACKEND_HOST");
            }
            
            try
            {
                _port = Int32.Parse(Environment.GetEnvironmentVariable("BACKEND_PORT"));
            }
            catch (ArgumentNullException e)
            {
                _logger.LogInformation("BACKEND_PORT is NULL");
            }
            catch (Exception e)
            {
                _logger.LogError("error => " + e.Message);
            }

            if (Environment.GetEnvironmentVariable("BACKEND_URI") != null) {
                _uri = Environment.GetEnvironmentVariable("BACKEND_URI");
            }
        }

        [HttpGet]
        public async Task<WeatherForecast[]> Get()
        {
            var client = _httpClientFactory.CreateClient();
            client.BaseAddress = new Uri("http://" + _host + ":" + _port + "/");
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            client.DefaultRequestHeaders.Add("User-Agent", "HttpClientFactory-Sample");

            var response = await client.GetAsync(_uri);

            if (!response.IsSuccessStatusCode) {
                _logger.LogError("Problem when calling client service code: " + response.StatusCode);
            }

            response.EnsureSuccessStatusCode();
            
            using var responseStream = await response.Content.ReadAsStreamAsync(); 
           
            var weatherForecasts = await JsonSerializer.DeserializeAsync<WeatherForecast[]>(responseStream, options);
            return weatherForecasts;
        }
    }
}
