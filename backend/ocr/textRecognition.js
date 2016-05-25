////////////////////////////// Configuration ////////////////////////////////////

// Import Google Cloud Library to handle authenticating 
// and communicating with Cloud Vision API. 
// Import Nearest Neighbour Library.
var gcloud = require('gcloud');
var nn = require('nearest-neighbor');


// GOOGLE_APPLICATION_CREDENTIALS and GCLOUD_PROJECT
// environment variables should have already been set
var projectId = process.env.GCLOUD_PROJECT;

// Initialize gcloud
gcloud = gcloud({
  projectId: projectId
});

// Obtain reference to the vision component
var vision = gcloud.vision();


///////////////////////////////////////////////////////////////////////////////////

var items = [
    { title: "Machine Learning", author: "Steven Kingaby"}, 
    { title: "Dynamical Systems and Deep Learning", author: "Andrew Finn"}, 
    { title: "Web Security", author: "Dane Sherburn"}, 
    { title: "Networks", author: "Sacha Cohen-Scali"}, 
    { title: "Real Analysis", author: "Roxie Ursu"}, 
    { title: "Mathematical Methods", author: "Lucy Pollock"}, 
    { title: "Compilers", author: "Maisie Robinson"}, 
    { title: "Operating Systems", author: "Macks Thrower"}, 
    { title: "Scientific Computation", author: "Dan Moore"} 
]




var fields = [
  { name: "title", measure: nn.comparisonMethods.word },
  { name: "author", measure: nn.comparisonMethods.word }
];


// Uses the Vision API to detect labels in the given file.
function detectText(inputFile, callback)  {
    // Make a call to the Vision API to identify text
    vision.detectText(inputFile, { verbose: true }, function(err, text, apiResponse) {
        if (err) {
            return callback(err);
        }

        callback(null, text);    
    });
}

// Main program
function main(inputFile, callback) {
    detectText(inputFile, function (err, text) {
        if (err) {
            return callback(err);
        }

        console.log(text[0].desc + '\n');
        
        var query = { name: text[0].desc, author: text[0].desc };
        
        nn.findMostSimilar(query, items, fields, function(nearestNeighbor, probability) {   
            console.log(nearestNeighbor);
            console.log(probability);
        });
    });
}


// Extract passed argument for image filename
if (module === require.main) {
    if (process.argv.length < 3) {
        console.log('Usage: node labelDetection <inputFile>');
        process.exit(1);
    }
    
    var inputFile = process.argv[2];
    main(inputFile, console.log);
}