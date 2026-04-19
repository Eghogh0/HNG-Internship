const express = require("express");
const cors = require("cors");
const profileRoutes = require("./routes/profileRoutes");

const app = express();

app.use(cors({ origin: "*" }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("API working");
});

app.get("/test-apis", async (req, res) => {
  const fetchExternalData = require("./services/externalService");
  try {
    const result = await fetchExternalData("john");
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message, type: err.type });
  }
});

app.use("/api", profileRoutes);

module.exports = app;