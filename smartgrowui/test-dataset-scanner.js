// Quick test for Gemini API functionality
import { yoloDatasetScanner } from './services/yoloDatasetScanner';

// Test the dataset scanner
async function testDatasetScanner() {
  console.log('Testing YOLOv11 Dataset Scanner...');
  
  try {
    // Test with "tomato" query
    console.log('\n=== Testing with "tomato" query ===');
    const tomatoResult = await yoloDatasetScanner.scanDatasetsForQuery('tomato');
    console.log('Result:', tomatoResult);
    
    // Test with "garlic" query
    console.log('\n=== Testing with "garlic" query ===');
    const garlicResult = await yoloDatasetScanner.scanDatasetsForQuery('garlic');
    console.log('Result:', garlicResult);
    
    // Test with unrelated query
    console.log('\n=== Testing with "car" query ===');
    const carResult = await yoloDatasetScanner.scanDatasetsForQuery('car');
    console.log('Result:', carResult);
    
  } catch (error) {
    console.error('Test failed:', error);
  }
}

// Run the test
testDatasetScanner();
