interface CustomFlatButtonProps {
  label: string;
  href?: string;
  bold?: boolean;
}

function CustomFlatButton(props: CustomFlatButtonProps) {
  return (
    <a
      className={`p-2 items-center text-sm ${
        props.bold ? "font-bold" : "font-normal"
      }  text-gray-900 hover:text-primary`}
      href={props.href}
    >
      {props.label}
    </a>
  );
}
export default CustomFlatButton;
