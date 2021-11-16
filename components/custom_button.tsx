import { Button, useTheme, withStyles } from "@material-ui/core";

function CustomButton(props: any) {
  const theme = useTheme();

  return (
    <Button
      variant="contained"
      disableElevation
      style={{
        padding: "12px 24px",
        borderRadius: "100px",
        backgroundColor: `${theme.palette.secondary.main}`,
        color: "#ffffff",
        textTransform: "capitalize",
        fontWeight: "bold",
      }}
      {...props}
    />
  );
}
export default CustomButton;
