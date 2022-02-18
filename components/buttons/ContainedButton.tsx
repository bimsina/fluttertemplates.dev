import { Button, Typography, useTheme } from "@mui/material";
import { makeStyles } from "@material-ui/core/styles";

interface CustomContainedButtonProps {
  label: string;
  endIcon?: any;
  href?: string;
  ariaLabel?: string;
  reverse?: boolean;
}

const useStyles = makeStyles({
  iconStyle: {
    fontSize: "1px",
    marginLeft: "4px",
  },
});

function CustomContainedButton(props: CustomContainedButtonProps) {
  const theme = useTheme();
  // const styles = useStyles();

  return (
    <Button
      variant="contained"
      href={props.href}
      disableElevation
      endIcon={props.endIcon}
      style={{
        padding: "12px 32px",
        backgroundColor: `${theme.palette.secondary.main}`,
        color: "#ffffff",
        textTransform: "capitalize",
        fontWeight: "bold",
        borderRadius: "10rem",
      }}
    >
      {props.label}
    </Button>
  );
}
export default CustomContainedButton;
