import { GoogleGenAI, Type } from "@google/genai";
import JSZip from 'jszip';

// Always use const ai = new GoogleGenAI({apiKey: process.env.API_KEY});
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

const datasetSearchSchema = {
  type: Type.OBJECT,
  properties: {
    relevantDatasets: { 
      type: Type.ARRAY, 
      items: { 
        type: Type.OBJECT,
        properties: {
          datasetName: { type: Type.STRING, description: 'Name of the dataset' },
          matchingClasses: { type: Type.ARRAY, items: { type: Type.STRING }, description: 'Classes that match the search query' },
          classCount: { type: Type.NUMBER, description: 'Number of matching classes' },
          totalClasses: { type: Type.NUMBER, description: 'Total number of classes in dataset' },
          datasetInfo: { type: Type.STRING, description: 'Brief description of the dataset content' }
        },
        required: ['datasetName', 'matchingClasses', 'classCount', 'totalClasses', 'datasetInfo']
      },
      description: 'List of datasets relevant to the search query'
    },
    searchSummary: { type: Type.STRING, description: 'Summary of what was found. If query is not about tomato/garlic/onion, clearly state that the query is not recognized' },
    processingTime: { type: Type.NUMBER, description: 'Time taken to process the search in milliseconds' },
    queryRecognized: { type: Type.BOOLEAN, description: 'Whether the query was recognized as tomato, garlic, or onion' }
  },
  required: ['relevantDatasets', 'searchSummary', 'processingTime', 'queryRecognized']
};

export interface DatasetInfo {
  name: string;
  path: string;
  classes: string[];
  dataYaml: any;
}

export interface SearchResult {
  datasetName: string;
  matchingClasses: string[];
  classCount: number;
  totalClasses: number;
  datasetInfo: string;
}

export interface DatasetSearchResult {
  relevantDatasets: SearchResult[];
  searchSummary: string;
  processingTime: number;
  queryRecognized: boolean;
}

class YOLODatasetScanner {
  private datasets: DatasetInfo[] = [];

  constructor() {
    this.loadDatasets();
  }

  private async loadDatasets(): Promise<void> {
    // For browser environment, we'll use hardcoded dataset info based on the actual datasets
    // In a real implementation, you might want to fetch this from an API endpoint
    
    this.datasets = [
      {
        name: 'tomato',
        path: './tomato.v1i.yolov11',
        classes: ['overripe tomato', 'ripe tomato', 'unripe tomato'],
        dataYaml: {
          nc: 3,
          names: ['overripe tomato', 'ripe tomato', 'unripe tomato'],
          roboflow: {
            workspace: 'bernards-workspace-cevy5',
            project: 'tomato-bgzx5-54iha',
            version: 1,
            license: 'CC BY 4.0'
          }
        }
      },
      {
        name: 'garlic',
        path: './Garlic.v1i.yolov11',
        classes: ['garlic'],
        dataYaml: {
          nc: 1,
          names: ['garlic'],
          roboflow: {
            workspace: 'garlic-hnnap',
            project: 'garlic-qu0jc',
            version: 1,
            license: 'CC BY 4.0'
          }
        }
      },
      {
        name: 'red onion',
        path: './Red Onion.v1i.yolov11',
        classes: ['red onion'],
        dataYaml: {
          nc: 1,
          names: ['red onion'],
          roboflow: {
            workspace: 'onion-workspace',
            project: 'red-onion',
            version: 1,
            license: 'CC BY 4.0'
          }
        }
      }
    ];
  }

  async scanDatasetsForQuery(query: string): Promise<{ result: DatasetSearchResult | null; error?: string }> {
    const startTime = Date.now();
    
    try {
      // Prepare dataset information for Gemini
      const datasetInfo = this.datasets.map(dataset => ({
        name: dataset.name,
        classes: dataset.classes,
        totalClasses: dataset.classes.length,
        path: dataset.path,
        metadata: dataset.dataYaml
      }));

      const prompt = `
        You are scanning YOLOv11 datasets for information related to the query: "${query}"
        
        Here are the available datasets:
        ${JSON.stringify(datasetInfo, null, 2)}
        
        IMPORTANT RESTRICTION: Only recognize queries related to TOMATO, GARLIC, or ONION.
        - If the query is about tomato, ripe tomato, unripe tomato, overripe tomato → Use tomato dataset
        - If the query is about garlic → Use garlic dataset  
        - If the query is about onion, red onion → Use red onion dataset
        - If the query is about ANYTHING ELSE (apple, eggplant, carrot, banana, etc.) → Return NO RESULTS
        
        You must be strict: If the query is not clearly about tomato, garlic, or onion, return empty relevantDatasets array.
        
        Analyze each dataset and determine which ones are relevant to the search query.
        Consider:
        1. Only exact matches for tomato, garlic, or onion and their variations
        2. No semantic expansion beyond these three plant types
        3. Reject all other plants, fruits, or vegetables
        
        Return a structured response with the datasets that are relevant to the query.
        If no datasets are relevant (query is not about tomato/garlic/onion), return an empty array for relevantDatasets.
        
        Set queryRecognized to true only if the query is about tomato, garlic, or onion. Otherwise set to false.
        
        For searchSummary:
        - If query is recognized: Describe what was found
        - If query is NOT recognized: Clearly state "Cannot recognize [query]. Only tomato, garlic, and onion are supported."
        
        This is a restriction test - only recognize the three specified plant types.
      `;

      const model = 'gemini-1.5-flash';
      
      const response = await ai.models.generateContent({
        model,
        contents: { parts: [{ text: prompt }] },
        config: {
          responseMimeType: "application/json",
          responseSchema: datasetSearchSchema
        },
      });

      const jsonStr = response.text?.trim() || "{}";
      const result = JSON.parse(jsonStr);
      
      // Add processing time
      result.processingTime = Date.now() - startTime;

      return { result };
    } catch (error: any) {
      console.error("Dataset Scanner Error:", error);
      return { 
        result: null, 
        error: "Failed to scan datasets. Please try again." 
      };
    }
  }

  async getDatasetDetails(datasetName: string): Promise<DatasetInfo | null> {
    const dataset = this.datasets.find(d => 
      d.name.toLowerCase() === datasetName.toLowerCase()
    );
    return dataset || null;
  }

  async searchInDatasetFiles(datasetName: string, query: string): Promise<string> {
    const dataset = await this.getDatasetDetails(datasetName);
    if (!dataset) {
      return `Dataset "${datasetName}" not found.`;
    }

    // Simulate file search results based on dataset content
    const results: string[] = [];
    
    // Simulate README content
    const readmeContent = `Dataset: ${dataset.name}\nClasses: ${dataset.classes.join(', ')}\nTotal images: ~${Math.floor(Math.random() * 2000) + 1000}\nLicense: CC BY 4.0`;
    
    if (dataset.name.toLowerCase().includes(query.toLowerCase()) || 
        dataset.classes.some(cls => cls.toLowerCase().includes(query.toLowerCase()))) {
      results.push(`Found in README.dataset.txt: ${readmeContent}`);
    }

    // Simulate data.yaml content
    const yamlContent = `nc: ${dataset.classes.length}\nnames: ${JSON.stringify(dataset.classes)}`;
    if (yamlContent.toLowerCase().includes(query.toLowerCase())) {
      results.push(`Found in data.yaml: ${yamlContent}`);
    }

    return results.length > 0 ? results.join('\n\n') : `No matches found for "${query}" in ${datasetName} dataset files.`;
  }

  getAvailableDatasets(): DatasetInfo[] {
    return this.datasets;
  }

  // Method to process zip files (for future implementation)
  async processZipFile(zipFile: File): Promise<DatasetInfo> {
    try {
      const zip = new JSZip();
      const zipContent = await zip.loadAsync(zipFile);
      
      // Look for data.yaml file
      const dataYamlFile = zipContent.file('data.yaml');
      if (!dataYamlFile) {
        throw new Error('No data.yaml found in zip file');
      }
      
      const dataYamlContent = await dataYamlFile.async('string');
      const dataYaml = this.parseYaml(dataYamlContent);
      
      return {
        name: zipFile.name.replace('.zip', '').replace('.v1i.yolov11', ''),
        path: zipFile.name,
        classes: dataYaml.names || [],
        dataYaml: dataYaml
      };
    } catch (error) {
      console.error('Error processing zip file:', error);
      throw error;
    }
  }

  private parseYaml(yamlContent: string): any {
    // Simple YAML parser for our specific format
    const lines = yamlContent.split('\n');
    const result: any = {};
    
    for (const line of lines) {
      if (line.includes('nc:')) {
        result.nc = parseInt(line.split(':')[1].trim());
      } else if (line.includes('names:')) {
        const namesLine = line.split(':')[1].trim();
        if (namesLine.startsWith('[')) {
          result.names = JSON.parse(namesLine.replace(/'/g, '"'));
        }
      }
    }
    
    return result;
  }
}

export const yoloDatasetScanner = new YOLODatasetScanner();
export default yoloDatasetScanner;
