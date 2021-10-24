import { Button, useTheme, withStyles } from "@material-ui/core";

// const CustomButton = withStyles({
//   root: {
//     display: "inline-block",
//     padding: "10px 16px",
//     minHeight: 0,
//     minWidth: 0,

//   },
//   label: {
//     textTransform: "capitalize",
//   },
// })(Button);

function CustomButton(props: any) {
  const { classes, children } = props;
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
      }}
    >
      <b>{children}</b>
    </Button>
  );
}
export default CustomButton;
