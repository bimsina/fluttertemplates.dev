interface CustomContainedButtonProps {
  label: string;
  endIcon?: any;
  href?: string;
  ariaLabel?: string;
  reverse?: boolean;
}

function CustomContainedButton(props: CustomContainedButtonProps) {
  // const styles = useStyles();

  return (
    <div className="inline-flex rounded-md">
      <a
        href={props.href}
        className="inline-flex items-center justify-center px-5 py-3 text-base font-medium rounded-full text-white bg-primary"
      >
        <span>{props.label}</span>
        {props.endIcon && <div className="ml-2">{props.endIcon}</div>}
      </a>
    </div>
    // <Button
    //   variant="contained"
    //   href={props.href}
    //   disableElevation
    //   endIcon={props.endIcon}
    //   style={{
    //     padding: "12px 32px",
    //     backgroundColor: `${theme.palette.secondary.main}`,
    //     color: "#ffffff",
    //     textTransform: "capitalize",
    //     fontWeight: "bold",
    //     borderRadius: "10rem",
    //   }}
    // >
    //   {props.label}
    // </Button>
  );
}
export default CustomContainedButton;
