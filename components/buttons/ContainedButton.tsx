interface CustomContainedButtonProps {
  label: string;
  endIcon?: any;
  href?: string;
  ariaLabel?: string;
  reverse?: boolean;
  target?: string;
  rel?: string;
}

function CustomContainedButton(props: CustomContainedButtonProps) {
  const renderContent = () => {
    return (
      <div className="inline-flex rounded-md">
        <div className="inline-flex items-center justify-center px-5 py-3 text-base font-medium rounded-full text-white bg-primary">
          <span>{props.label}</span>
          {props.endIcon && <div className="ml-2">{props.endIcon}</div>}
        </div>
      </div>
    );
  };
  if (props.href) {
    return (
      <a href={props.href} target={props.target} rel={props.rel}>
        {renderContent()}
      </a>
    );
  } else return <>{renderContent()}</>;
}
export default CustomContainedButton;
