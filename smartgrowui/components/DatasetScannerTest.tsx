import React, { useState } from 'react';
import { Search, Database, Clock, AlertCircle, CheckCircle, FileText } from 'lucide-react';
import { yoloDatasetScanner, DatasetSearchResult, DatasetInfo } from '../services/yoloDatasetScanner';

const DatasetScannerTest: React.FC = () => {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<DatasetSearchResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [availableDatasets, setAvailableDatasets] = useState<DatasetInfo[]>([]);
  const [fileSearchResults, setFileSearchResults] = useState<{ [key: string]: string }>({});

  React.useEffect(() => {
    // Load available datasets
    const datasets = yoloDatasetScanner.getAvailableDatasets();
    setAvailableDatasets(datasets);
  }, []);

  const handleSearch = async () => {
    if (!query.trim()) {
      setError('Please enter a search query');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);
    setFileSearchResults({});

    try {
      const startTime = Date.now();
      const response = await yoloDatasetScanner.scanDatasetsForQuery(query);
      
      if (response.result) {
        setResult(response.result);
        
        // Also search in individual dataset files for more detailed results
        const fileResults: { [key: string]: string } = {};
        for (const dataset of availableDatasets) {
          const fileResult = await yoloDatasetScanner.searchInDatasetFiles(dataset.name, query);
          fileResults[dataset.name] = fileResult;
        }
        setFileSearchResults(fileResults);
      } else {
        setError(response.error || 'No results found');
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred during search');
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6 space-y-6">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
          <Database className="w-6 h-6 text-blue-600" />
          YOLOv11 Dataset Scanner - Speed Test
        </h2>
        
        <p className="text-gray-600 mb-6">
          Test Gemini's ability to scan YOLOv11 datasets for relevant information. 
          This is a feasibility test to measure search speed and accuracy.
        </p>

        {/* Scope Warning */}
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-yellow-600 mt-0.5" />
            <div>
              <h4 className="font-semibold text-yellow-800">Restricted Scope</h4>
              <p className="text-yellow-700 text-sm mt-1">
                Only recognizes: <strong>tomato</strong>, <strong>garlic</strong>, and <strong>onion</strong>. 
                All other queries (apple, eggplant, etc.) will be rejected.
              </p>
            </div>
          </div>
        </div>

        {/* Search Input */}
        <div className="flex gap-4 mb-6">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Enter search term (e.g., 'tomato', 'garlic', 'onion')"
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <button
            onClick={handleSearch}
            disabled={loading || !query.trim()}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {loading ? 'Scanning...' : 'Scan Datasets'}
          </button>
        </div>

        {/* Available Datasets */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold mb-3">Available Datasets:</h3>
          <div className="flex gap-3 flex-wrap">
            {availableDatasets.map((dataset) => (
              <div key={dataset.name} className="bg-gray-100 px-3 py-2 rounded-lg">
                <span className="font-medium">{dataset.name}</span>
                <span className="text-gray-600 ml-2">({dataset.classes.length} classes)</span>
              </div>
            ))}
          </div>
        </div>

        {/* Loading State */}
        {loading && (
          <div className="flex items-center justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <span className="ml-3 text-gray-600">Scanning datasets with Gemini...</span>
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-red-600 mt-0.5" />
            <div>
              <h4 className="font-semibold text-red-800">Error</h4>
              <p className="text-red-700">{error}</p>
            </div>
          </div>
        )}

        {/* Results */}
        {result && (
          <div className="space-y-6">
            {/* Query Recognition Status */}
            <div className={`${result.queryRecognized ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'} border rounded-lg p-4`}>
              <div className="flex items-start gap-3">
                {result.queryRecognized ? (
                  <CheckCircle className="w-5 h-5 text-green-600 mt-0.5" />
                ) : (
                  <AlertCircle className="w-5 h-5 text-red-600 mt-0.5" />
                )}
                <div className="flex-1">
                  <h4 className={`font-semibold ${result.queryRecognized ? 'text-green-800' : 'text-red-800'}`}>
                    {result.queryRecognized ? 'Query Recognized' : 'Query Not Recognized'}
                  </h4>
                  <p className={`${result.queryRecognized ? 'text-green-700' : 'text-red-700'} mt-1`}>
                    {result.searchSummary}
                  </p>
                  <div className="flex items-center gap-2 mt-2 text-sm text-gray-600">
                    <Clock className="w-4 h-4" />
                    <span>Processing time: {result.processingTime}ms</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Relevant Datasets */}
            {result.relevantDatasets.length > 0 && (
              <div>
                <h3 className="text-lg font-semibold mb-3">Relevant Datasets:</h3>
                <div className="space-y-4">
                  {result.relevantDatasets.map((dataset, index) => (
                    <div key={index} className="bg-white border border-gray-200 rounded-lg p-4">
                      <h4 className="font-semibold text-lg mb-2">{dataset.datasetName}</h4>
                      <p className="text-gray-600 mb-3">{dataset.datasetInfo}</p>
                      
                      <div className="grid grid-cols-2 gap-4 mb-3">
                        <div>
                          <span className="text-sm text-gray-500">Matching Classes:</span>
                          <div className="flex gap-2 flex-wrap mt-1">
                            {dataset.matchingClasses.map((cls, clsIndex) => (
                              <span key={clsIndex} className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">
                                {cls}
                              </span>
                            ))}
                          </div>
                        </div>
                        <div className="text-sm">
                          <div className="text-gray-500">Classes Found:</div>
                          <div className="font-semibold">{dataset.classCount} / {dataset.totalClasses}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* File Search Results */}
            <div>
              <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                <FileText className="w-5 h-5" />
                File Search Results:
              </h3>
              <div className="space-y-4">
                {Object.entries(fileSearchResults).map(([datasetName, fileResult]) => (
                  <div key={datasetName} className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                    <h4 className="font-semibold mb-2">{datasetName}</h4>
                    <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono bg-white p-3 rounded border">
                      {fileResult}
                    </pre>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default DatasetScannerTest;
