package DemoGHAdoption.InventoryApi;

import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;


@RestController
class InventoryApiController {

    private final ConcurrentMapCache cache;

    public InventoryApiController(ConcurrentMapCache cache) {
        this.cache = cache;
    }

    @GetMapping("/inventory/{productId}")
    public int getInventory(@PathVariable String productId) {
        String memCacheKey = productId + "-inventory";
        Integer inventoryValue = cache.get(memCacheKey, Integer.class);

        if (inventoryValue == null) {
            inventoryValue = new Random().nextInt(100) + 1;
            cache.put(memCacheKey, inventoryValue);
        }

        return inventoryValue;
    }
}