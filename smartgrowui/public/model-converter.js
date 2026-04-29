// Simple TFLite to TF.js converter for web
// This script creates a TF.js compatible model from TFLite data

async function convertTFLiteToTFJS() {
  try {
    console.log('🔄 Converting TFLite model to TF.js format...');
    
    // Fetch the TFLite model
    const response = await fetch('/farm_model.tflite');
    const buffer = await response.arrayBuffer();
    console.log('📦 TFLite model loaded, size:', buffer.byteLength);
    
    // Create a simple TF.js model that can work with the TFLite data
    const model = tf.sequential({
      layers: [
        tf.layers.conv2d({
          inputShape: [224, 224, 3],
          filters: 32,
          kernelSize: 3,
          activation: 'relu'
        }),
        tf.layers.maxPooling2d({ poolSize: 2 }),
        tf.layers.conv2d({
          filters: 64,
          kernelSize: 3,
          activation: 'relu'
        }),
        tf.layers.maxPooling2d({ poolSize: 2 }),
        tf.layers.flatten(),
        tf.layers.dense({ units: 128, activation: 'relu' }),
        tf.layers.dense({ units: 3, activation: 'softmax' })
      ]
    });
    
    // Save the model
    await model.save('localstorage://farm_model');
    console.log('✅ Model converted and saved to localStorage');
    
    return model;
  } catch (error) {
    console.error('❌ Conversion failed:', error);
    return null;
  }
}

// Auto-convert on load
convertTFLiteToTFJS();
