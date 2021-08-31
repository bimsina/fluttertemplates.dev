import { Button, withStyles } from "@material-ui/core";
import React from "react";
const CustomButton = withStyles({
  root: {
    display: "inline-block",
    padding: "10px 16px",
    minHeight: 0,
    minWidth: 0,
  },
  label: {
    textTransform: "capitalize",
  },
})(Button);

export default CustomButton;
