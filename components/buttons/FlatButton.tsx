import { Button, useTheme } from "@mui/material";

interface CustomFlatButtonProps {
  label: string;
  href?: string;
  bold?: boolean;
}

function CustomFlatButton(props: CustomFlatButtonProps) {
  return (
    <Button
      variant="text"
      color="inherit"
      href={props.href}
      style={{
        textTransform: "capitalize",
        fontWeight: `${props.bold ? "bold" : "normal"}`,
      }}
    >
      {props.label}
    </Button>
  );
}
export default CustomFlatButton;
