package service.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class WeightLogRequest {
    private Long userId;
    private double weight;
    private LocalDate date;
}
