import { Button, makeStyles, Typography, useTheme } from "@material-ui/core";

interface CustomContainedButtonProps {
  label: string;
  icon?: any;
  href?: string;
  ariaLabel?: string;
  reverse?: boolean;
}

const useStyles = makeStyles((theme) => ({
  iconStyle: {
    fontSize: "1px",
    marginLeft: "8px",
  },
}));

function CustomContainedButton(props: CustomContainedButtonProps) {
  const theme = useTheme();
  const styles = useStyles();

  return (
    <Button
      variant="contained"
      href={props.href}
      disableElevation
      style={{
        padding: "12px 24px",
        backgroundColor: `${theme.palette.secondary.main}`,
        color: "#ffffff",
        textTransform: "capitalize",
        fontWeight: "bold",
      }}
    >
      <div>{props.label}</div>
      {props.icon && <div className={styles.iconStyle}>{props.icon}</div>}
    </Button>
  );
}
export default CustomContainedButton;
