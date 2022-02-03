import { Button, makeStyles, useTheme } from "@material-ui/core";

interface CustomFlatButtonProps {
  label: string;
  href?: string;
}

const useStyles = makeStyles((theme) => ({
  button: {
    "&:hover": {
      backgroundColor: `${theme.palette.secondary.main}15`,
      color: theme.palette.secondary.main,
    },
  },
}));

function CustomFlatButton(props: CustomFlatButtonProps) {
  const styles = useStyles();

  return (
    <Button
      className={styles.button}
      variant="text"
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
