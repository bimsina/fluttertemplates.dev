import { Button, useTheme } from "@mui/material";
import { makeStyles } from "@material-ui/core/styles";

interface CustomFlatButtonProps {
  label: string;
  href?: string;
}

function CustomFlatButton(props: CustomFlatButtonProps) {
  return (
    <Button
      variant="text"
      color="inherit"
      href={props.href}
      style={{
        textTransform: "capitalize",
        fontWeight: "bold",
      }}
    >
      {props.label}
    </Button>
  );
}
export default CustomFlatButton;
