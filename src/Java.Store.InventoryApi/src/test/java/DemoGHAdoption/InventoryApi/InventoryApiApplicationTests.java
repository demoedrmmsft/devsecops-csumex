package DemoGHAdoption.InventoryApi;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cache.concurrent.ConcurrentMapCache;

import java.util.Random;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class InventoryApiApplicationTests {

	@Mock
    private ConcurrentMapCache cache;

    @InjectMocks
    private InventoryApiController inventoryApiController;

    @BeforeEach
    void setUp() {
        inventoryApiController = new InventoryApiController(cache);
    }

    @Test
    void testGetInventory_CacheHit() {
        String productId = "123";
        String memCacheKey = productId + "-inventory";
        Integer cachedValue = 50;

        when(cache.get(memCacheKey, Integer.class)).thenReturn(cachedValue);

        int result = inventoryApiController.getInventory(productId);

        assertEquals(cachedValue, result);
        verify(cache, times(1)).get(memCacheKey, Integer.class);
        verify(cache, never()).put(anyString(), anyInt());
    }

    @Test
    void testGetInventory_CacheMiss() {
        String productId = "123";
        String memCacheKey = productId + "-inventory";

        when(cache.get(memCacheKey, Integer.class)).thenReturn(null);

        int result = inventoryApiController.getInventory(productId);

        verify(cache, times(1)).get(memCacheKey, Integer.class);
        verify(cache, times(1)).put(eq(memCacheKey), anyInt());
    }
}