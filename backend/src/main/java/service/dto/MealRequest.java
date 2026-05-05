package service.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class MealRequest {
    private Long userId;
    private Long foodId;
    private String foodName;
    private String mealType;
    private double gram;
    private double calories;
    private double protein;
    private double carbs;
    private double fat;
    private LocalDate date;
}
