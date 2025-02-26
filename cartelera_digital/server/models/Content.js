const mongoose = require('mongoose');

const ContentSchema = new mongoose.Schema({
    id: String,
    title: String,
    imageUrl: String,
    type: String,
    metadata: {
        type: Map,
        of: mongoose.Schema.Types.Mixed
    },
    uploadedAt: Date,
    status: String
});

module.exports = mongoose.model('Content', ContentSchema); 