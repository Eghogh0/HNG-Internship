const express = require("express");
const cors = require("cors");
const profileRoutes = require("./routes/profileRoutes");

const app = express();

app.use(cors({ origin: "*" }));
app.use(express.json());

// IMPORTANT: this line must exist
app.use("/api", profileRoutes);

module.exports = app;