package com.senkim.nutrition.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

@Service
public class AiService {

    private final String API_KEY = "YOUR_API_KEY";
    private final ObjectMapper mapper = new ObjectMapper();

    public JsonNode generateMealPlan(Map<String, Object> data) {

        try {
            String prompt = buildPrompt(data);

            String body = """
            {
              "contents": [{
                "parts": [{
                  "text": "%s"
                }]
              }]
            }
            """.formatted(prompt);

            HttpClient client = HttpClient.newHttpClient();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(
                        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=" + API_KEY))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response =
                    client.send(request, HttpResponse.BodyHandlers.ofString());

            JsonNode root = mapper.readTree(response.body());

            if (root.has("error")) {
                System.out.println("API Error: " + root.get("error"));
                return mapper.readTree(buildFallbackJson(data));
            }

            JsonNode candidates = root.path("candidates");

            if (!candidates.isArray() || candidates.size() == 0) {
                System.out.println("No candidates in response");
                return mapper.readTree(buildFallbackJson(data));
            }

            String text = candidates.get(0)
                    .path("content")
                    .path("parts")
                    .get(0)
                    .path("text")
                    .asText();

            // 🔥 CLEAN
            text = cleanJson(text);

            // 🔥 PARSE JSON → OBJECT
            JsonNode aiResponse = mapper.readTree(text);
            
            // 🔥 ENRICH with metrics
            return enrichResponseWithMetrics(aiResponse, data);

        } catch (Exception e) {
            System.out.println("Exception in generateMealPlan: " + e.getMessage());
            e.printStackTrace();
            // Always return fallback with all fields
            try {
                return mapper.readTree(buildFallbackJson(data));
            } catch (Exception ex) {
                System.out.println("Error building fallback: " + ex.getMessage());
                ex.printStackTrace();
                return null;
            }
        }
    }

    // ===== ENRICH RESPONSE WITH METRICS =====
    private JsonNode enrichResponseWithMetrics(JsonNode response, Map<String, Object> data) {
        try {
            int tdee = getTDEE(data);
            int dailyCalories = calculateDailyCalories(data);
            double height = Double.parseDouble(data.get("height").toString());
            double weight = Double.parseDouble(data.get("weight").toString());
            double bmi = weight / Math.pow(height / 100, 2);
            
            System.out.println("Enrichment values - TDEE: " + tdee + ", DailyCalories: " + dailyCalories + ", BMI: " + bmi);
            
            // If response is not an object, return fallback
            if (!response.isObject()) {
                System.out.println("Response is not an object, using fallback");
                return mapper.readTree(buildFallbackJson(data));
            }
            
            // Convert to mutable ObjectNode
            ObjectNode enriched = mapper.createObjectNode();
            
            // Copy all fields from original response
            if (response.isObject()) {
                enriched.setAll((ObjectNode) response);
            }
            
            // Always override with calculated values
            enriched.put("tdee", tdee);
            enriched.put("dailyCalories", dailyCalories);
            enriched.put("bmi", bmi);
            
            // Ensure plan exists
            if (!enriched.has("plan") || !enriched.get("plan").isArray()) {
                System.out.println("Plan missing or invalid, creating default plan");
                enriched.set("plan", mapper.readTree(buildFallbackJson(data)).get("plan"));
            }

            // Force each day total calories close to target dailyCalories
            normalizePlanCalories(enriched, dailyCalories);
            
            System.out.println("Enriched response: " + enriched.toPrettyString());
            return enriched;
        } catch (Exception e) {
            System.out.println("Error enriching response: " + e.getMessage());
            e.printStackTrace();
            // On any error, return fallback
            try {
                return mapper.readTree(buildFallbackJson(data));
            } catch (Exception ex) {
                System.out.println("Critical error creating fallback: " + ex.getMessage());
                ex.printStackTrace();
                return null;
            }
        }
    }

    // ===== CLEAN JSON =====
    private String cleanJson(String text) {
        return text
                .replace("```json", "")
                .replace("```", "")
                .replace("\\n", "")
                .replace("\\\"", "\"")
                .trim();
    }

    // ===== PROMPT =====
    private String buildPrompt(Map<String, Object> data) {
        int dailyCalories = calculateDailyCalories(data);
        int planDays = getPlanDays(data);
        double height = Double.parseDouble(data.get("height").toString());
        double weight = Double.parseDouble(data.get("weight").toString());
        double bmi = weight / Math.pow(height / 100, 2);
        
        return String.format("""
        Bạn là chuyên gia dinh dưỡng tạo kế hoạch ăn uống chi tiết.
        
        CHỈ trả về JSON, KHÔNG markdown, KHÔNG giải thích gì khác.
        
        Hãy tạo kế hoạch ăn uống cho %d ngày.
        
        Số ngày phải đúng bằng: %d
        
        **QUAN TRỌNG - Tuân thủ nghiêm túc:**
        - Mỗi ngày PHẢI có tổng cộng CHÍNH XÁC ~%d kcal (sáng + trưa + tối)
        - Mỗi ngày PHẢI khác nhau - không lặp lại meal giữa các ngày
        - Sáng: khoảng 20%% energi (~%d kcal)
        - Trưa: khoảng 40%% energi (~%d kcal) 
        - Tối: khoảng 40%% energi (~%d kcal)
        - Thực phẩm phải đa dạng, dễ chuẩn bị, phù hợp VN
        
        Format JSON bắt buộc:
        {
          "bmi": %.1f,
          "tdee": %d,
          "dailyCalories": %d,
          "plan": [
            {
              "day": 1,
              "dailyCalories": %d,
              "meals": {
                "breakfast": [
                  {"name": "Tên món", "grams": số gram, "cal": số kcal}
                ],
                "lunch": [
                  {"name": "Tên món", "grams": số gram, "cal": số kcal}
                ],
                "dinner": [
                  {"name": "Tên món", "grams": số gram, "cal": số kcal}
                ]
              }
            }
          ]
        }
        
        Công thức tính toán sử dụng:
        BMR (Mifflin-St Jeor):
        - Nam: BMR = 10×weight(kg) + 6.25×height(cm) - 5×age + 5
        - Nữ: BMR = 10×weight(kg) + 6.25×height(cm) - 5×age - 161
        TDEE = BMR × 1.2 (sedentary activity level)
        
        Điều chỉnh theo mục tiêu:
        - Giảm cân: khoảng 80%% TDEE
        - Tăng cân: khoảng 115%% TDEE
        - Giữ dáng: TDEE (không thay đổi)
        
        Thông tin người dùng:
        Height: %s cm
        Weight: %s kg
        Age: %s
        Gender: %s
        Goal: %s
        Time: %s %s
        """,
                planDays,
                planDays,
                dailyCalories,
                Math.round(dailyCalories * 0.2),
                Math.round(dailyCalories * 0.4),
                Math.round(dailyCalories * 0.4),
                bmi,
                getTDEE(data),
                dailyCalories,
                dailyCalories,
                data.get("height"),
                data.get("weight"),
                data.get("age"),
                data.get("gender"),
                data.get("goal"),
                data.get("timeValue"),
                data.get("timeUnit")
        );
    }

    // ===== CALCULATE DAILY CALORIES =====
    private int calculateDailyCalories(Map<String, Object> data) {
        double height = Double.parseDouble(data.get("height").toString());
        double weight = Double.parseDouble(data.get("weight").toString());
        int age = Integer.parseInt(data.get("age").toString());
        String gender = data.get("gender").toString();
        String goal = data.get("goal").toString();

        // Mifflin-St Jeor formula for BMR
        double bmr;
        if ("Nam".equals(gender)) {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        }

        // Calculate TDEE with sedentary activity level (1.2)
        double tdee = bmr * 1.2;

        // Adjust based on goal (percentage-based for better plan quality)
        if ("Giảm cân".equals(goal)) {
            tdee = tdee * 0.80;
        } else if ("Tăng cân".equals(goal)) {
            tdee = tdee * 1.15;
        }
        // If "Giữ dáng", keep TDEE as is

        // Safety floor for sustainable plans
        double minCalories = "Nam".equals(gender) ? 1400 : 1200;
        if (tdee < minCalories) {
            tdee = minCalories;
        }

        return (int) tdee;
    }

    // ===== GET TDEE (Base without adjustment) =====
    private int getTDEE(Map<String, Object> data) {
        double height = Double.parseDouble(data.get("height").toString());
        double weight = Double.parseDouble(data.get("weight").toString());
        int age = Integer.parseInt(data.get("age").toString());
        String gender = data.get("gender").toString();

        // Mifflin-St Jeor formula for BMR
        double bmr;
        if ("Nam".equals(gender)) {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        }

        // Calculate TDEE with sedentary activity level (1.2)
        double tdee = bmr * 1.2;

        return (int) tdee;
    }

    // ===== GET MEALS BY DAY =====
    private String getMealsByDay(int day, int totalCal) {
        // All meals with different options
        String[][] breakfastOptions = {
            {"Trứng luộc", "100", "150"},
            {"Cơm chiên trứng", "150", "280"},
            {"Bánh mì + pate", "80", "220"},
            {"Sữa chua + granola", "150", "180"},
        };
        
        String[][] lunchOptions = {
            {"Cơm + ức gà", "300", "450"},
            {"Cơm + cá hồi nướng", "250", "420"},
            {"Cơm + thịt bò xào", "350", "480"},
            {"Mỳ gà", "300", "400"},
        };
        
        String[][] dinnerOptions = {
            {"Salad", "200", "150"},
            {"Canh chua cá", "300", "200"},
            {"Rau xào + tôm", "250", "180"},
            {"Súp rau củ", "300", "120"},
        };

        // Rotate meals by day
        int bIdx = (day - 1) % breakfastOptions.length;
        int lIdx = (day - 1) % lunchOptions.length;
        int dIdx = (day - 1) % dinnerOptions.length;

        int breakfastCal = (int) Math.round(totalCal * 0.20);
        int lunchCal = (int) Math.round(totalCal * 0.40);
        int dinnerCal = totalCal - breakfastCal - lunchCal;

        String breakfast = String.format(
            """
            [
              {"name": "%s", "grams": %s, "cal": %s}
            ]""",
            breakfastOptions[bIdx][0],
            breakfastOptions[bIdx][1],
            breakfastCal
        );

        String lunch = String.format(
            """
            [
              {"name": "%s", "grams": %s, "cal": %s}
            ]""",
            lunchOptions[lIdx][0],
            lunchOptions[lIdx][1],
            lunchCal
        );

        String dinner = String.format(
            """
            [
              {"name": "%s", "grams": %s, "cal": %s}
            ]""",
            dinnerOptions[dIdx][0],
            dinnerOptions[dIdx][1],
            dinnerCal
        );

        return String.format(
            """
            {
              "breakfast": %s,
              "lunch": %s,
              "dinner": %s
            }""",
            breakfast, lunch, dinner
        );
    }

    // ===== FALLBACK =====
    private String buildFallbackJson(Map<String, Object> data) {
        double height = Double.parseDouble(data.get("height").toString());
        double weight = Double.parseDouble(data.get("weight").toString());

        double bmi = weight / Math.pow(height / 100, 2);
        int expectedDays = getPlanDays(data);
        int tdee = getTDEE(data);
        int dailyCalories = calculateDailyCalories(data);
        
        StringBuilder planBuilder = new StringBuilder();
        for (int day = 1; day <= expectedDays; day++) {
            if (day > 1) planBuilder.append(",");
            planBuilder.append(String.format("""
            {
              "day": %d,
              "dailyCalories": %d,
              "meals": %s
            }""", day, dailyCalories, getMealsByDay(day, dailyCalories)));
        }
        
        return String.format("""
        {
          "bmi": %.1f,
          "tdee": %d,
          "dailyCalories": %d,
          "plan": [%s]
        }""", bmi, tdee, dailyCalories, planBuilder.toString());
    }

    private int getPlanDays(Map<String, Object> data) {
        int value = Integer.parseInt(data.get("timeValue").toString());
        String unit = data.get("timeUnit").toString();

        int days;
        if ("Tuần".equals(unit)) {
            days = value * 7;
        } else if ("Tháng".equals(unit)) {
            days = value * 30;
        } else {
            days = value;
        }

        // Bound for API stability
        if (days < 1) return 1;
        if (days > 90) return 90;
        return days;
    }

    private void normalizePlanCalories(ObjectNode enriched, int dailyTarget) {
        JsonNode planNode = enriched.get("plan");
        if (!(planNode instanceof ArrayNode plan)) return;

        for (JsonNode dayNode : plan) {
            if (!(dayNode instanceof ObjectNode dayObj)) continue;
            JsonNode mealsNode = dayObj.get("meals");
            if (!(mealsNode instanceof ObjectNode mealsObj)) continue;

            int breakfast = sumMealCalories(mealsObj.get("breakfast"));
            int lunch = sumMealCalories(mealsObj.get("lunch"));
            int dinner = sumMealCalories(mealsObj.get("dinner"));
            int currentTotal = breakfast + lunch + dinner;

            int breakfastTarget = (int) Math.round(dailyTarget * 0.20);
            int lunchTarget = (int) Math.round(dailyTarget * 0.40);
            int dinnerTarget = dailyTarget - breakfastTarget - lunchTarget;

            if (currentTotal <= 0) {
                setFirstMealCalories(mealsObj.get("breakfast"), breakfastTarget);
                setFirstMealCalories(mealsObj.get("lunch"), lunchTarget);
                setFirstMealCalories(mealsObj.get("dinner"), dinnerTarget);
            } else {
                scaleMealCalories(mealsObj.get("breakfast"), breakfastTarget, breakfast);
                scaleMealCalories(mealsObj.get("lunch"), lunchTarget, lunch);
                scaleMealCalories(mealsObj.get("dinner"), dinnerTarget, dinner);
            }

            dayObj.put("dailyCalories", dailyTarget);
        }
    }

    private int sumMealCalories(JsonNode mealArray) {
        if (!(mealArray instanceof ArrayNode arr)) return 0;
        int sum = 0;
        for (JsonNode item : arr) {
            sum += item.path("cal").asInt(0);
        }
        return sum;
    }

    private void scaleMealCalories(JsonNode mealArray, int target, int currentTotal) {
        if (!(mealArray instanceof ArrayNode arr) || arr.size() == 0) return;
        if (currentTotal <= 0) {
            setFirstMealCalories(arr, target);
            return;
        }

        double ratio = target / (double) currentTotal;
        int running = 0;
        for (int i = 0; i < arr.size(); i++) {
            JsonNode item = arr.get(i);
            if (!(item instanceof ObjectNode mealObj)) continue;

            int oldCal = item.path("cal").asInt(0);
            double oldGrams = item.path("grams").asDouble(-1);
            int newCal = (i == arr.size() - 1)
                    ? Math.max(1, target - running)
                    : Math.max(1, (int) Math.round(oldCal * ratio));
            running += newCal;
            mealObj.put("cal", newCal);

            // Keep kcal and grams consistent by preserving meal energy density.
            if (oldCal > 0 && oldGrams > 0) {
                double newGrams = oldGrams * newCal / oldCal;
                mealObj.put("grams", Math.max(1, Math.round(newGrams)));
            }
        }
    }

    private void setFirstMealCalories(JsonNode mealArray, int target) {
        if (!(mealArray instanceof ArrayNode arr) || arr.size() == 0) return;
        JsonNode first = arr.get(0);
        if (first instanceof ObjectNode firstObj) {
            int oldCal = first.path("cal").asInt(0);
            double oldGrams = first.path("grams").asDouble(-1);
            firstObj.put("cal", Math.max(1, target));
            if (oldCal > 0 && oldGrams > 0) {
                double newGrams = oldGrams * target / oldCal;
                firstObj.put("grams", Math.max(1, Math.round(newGrams)));
            }
        }
        for (int i = 1; i < arr.size(); i++) {
            JsonNode item = arr.get(i);
            if (item instanceof ObjectNode obj) {
                obj.put("cal", 0);
                if (obj.has("grams")) {
                    obj.put("grams", 0);
                }
            }
        }
    }
}