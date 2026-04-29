# YOLOv11 Dataset Scanner Test

This implementation provides a speed/feasibility test for using Gemini to scan YOLOv11 datasets.

## Features

- **Dataset Scanner**: Scans available YOLOv11 datasets (tomato, garlic, red onion)
- **Gemini Integration**: Uses Gemini 1.5 Flash for intelligent search
- **Speed Testing**: Measures processing time for each search
- **Browser Compatible**: Works entirely in the browser environment

## How to Test

1. Navigate to the SmartGrow AI application
2. Click on "Dataset Scanner" in the navigation menu
3. Enter search terms like:
   - "tomato" - should find tomato dataset with all 3 classes
   - "garlic" - should find garlic dataset
   - "onion" - should find red onion dataset
   - "vegetable" - might find multiple datasets
   - "fruit" - should find tomato dataset

## What It Tests

1. **Search Speed**: How long Gemini takes to analyze dataset information
2. **Semantic Understanding**: Can Gemini understand related terms (e.g., "onion" → "red onion")
3. **Structured Output**: Gemini's ability to return structured JSON responses
4. **Feasibility**: Whether this approach is practical for real-world use

## Dataset Structure

The scanner currently works with these datasets:
- **tomato.v1i.yolov11**: 3 classes (overripe tomato, ripe tomato, unripe tomato)
- **Garlic.v1i.yolov11**: 1 class (garlic)
- **Red Onion.v1i.yolov11**: 1 class (red onion)

## Technical Implementation

- Uses browser-compatible file reading (no Node.js fs module)
- Hardcoded dataset information for testing
- Includes placeholder file search functionality
- Measures and reports processing time

## Next Steps

After testing, you can decide whether to:
1. Use this Gemini-based approach for production
2. Implement precomputed embeddings for faster search
3. Use a trained YOLO model for direct image classification
4. Combine multiple approaches for optimal performance
