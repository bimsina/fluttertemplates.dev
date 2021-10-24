import { Button, useTheme, withStyles } from "@material-ui/core";

function CustomButton(props: any) {
  const theme = useTheme();

  return (
    <Button
      variant="contained"
      disableElevation
      style={{
        padding: "10px 16px",
        borderRadius: "4px",
        backgroundColor: `${theme.palette.secondary.main}25`,
        color: theme.palette.secondary.main,
        textTransform: "capitalize",
        fontWeight: "bold",
      }}
      {...props}
    />
  );
}
export default CustomButton;
