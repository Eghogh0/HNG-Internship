const express = require("express");
const router = express.Router();
const controller = require("../controllers/profileController");

router.post("/profiles", controller.createProfile);
router.get("/profiles", controller.getAllProfiles);
router.get("/profiles/:id", controller.getProfile);
router.delete("/profiles/:id", controller.deleteProfile);

module.exports = router;