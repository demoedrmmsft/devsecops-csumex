package DemoGHAdoption.InventoryApi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.context.annotation.Bean;


@SpringBootApplication
@EnableCaching
public class InventoryApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(InventoryApiApplication.class, args);
	}
	 @Bean
	 
    public ConcurrentMapCache cache() {
        return new ConcurrentMapCache("inventoryCache");
    }

}
