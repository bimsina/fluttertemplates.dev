(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[240],{5477:function(e,t,r){"use strict";var i=r(7462),a=r(5987),n=r(7294),s=(r(5697),r(6010)),o=r(6916),c=r(3871),l=44,d=n.forwardRef((function(e,t){var r=e.classes,o=e.className,d=e.color,u=void 0===d?"primary":d,f=e.disableShrink,m=void 0!==f&&f,h=e.size,k=void 0===h?40:h,p=e.style,v=e.thickness,x=void 0===v?3.6:v,y=e.value,_=void 0===y?0:y,D=e.variant,Z=void 0===D?"indeterminate":D,g=(0,a.Z)(e,["classes","className","color","disableShrink","size","style","thickness","value","variant"]),N={},S={},w={};if("determinate"===Z||"static"===Z){var b=2*Math.PI*((l-x)/2);N.strokeDasharray=b.toFixed(3),w["aria-valuenow"]=Math.round(_),N.strokeDashoffset="".concat(((100-_)/100*b).toFixed(3),"px"),S.transform="rotate(-90deg)"}return n.createElement("div",(0,i.Z)({className:(0,s.Z)(r.root,o,"inherit"!==u&&r["color".concat((0,c.Z)(u))],{determinate:r.determinate,indeterminate:r.indeterminate,static:r.static}[Z]),style:(0,i.Z)({width:k,height:k},S,p),ref:t,role:"progressbar"},w,g),n.createElement("svg",{className:r.svg,viewBox:"".concat(22," ").concat(22," ").concat(l," ").concat(l)},n.createElement("circle",{className:(0,s.Z)(r.circle,m&&r.circleDisableShrink,{determinate:r.circleDeterminate,indeterminate:r.circleIndeterminate,static:r.circleStatic}[Z]),style:N,cx:l,cy:l,r:(l-x)/2,fill:"none",strokeWidth:x})))}));t.Z=(0,o.Z)((function(e){return{root:{display:"inline-block"},static:{transition:e.transitions.create("transform")},indeterminate:{animation:"$circular-rotate 1.4s linear infinite"},determinate:{transition:e.transitions.create("transform")},colorPrimary:{color:e.palette.primary.main},colorSecondary:{color:e.palette.secondary.main},svg:{display:"block"},circle:{stroke:"currentColor"},circleStatic:{transition:e.transitions.create("stroke-dashoffset")},circleIndeterminate:{animation:"$circular-dash 1.4s ease-in-out infinite",strokeDasharray:"80px, 200px",strokeDashoffset:"0px"},circleDeterminate:{transition:e.transitions.create("stroke-dashoffset")},"@keyframes circular-rotate":{"0%":{transformOrigin:"50% 50%"},"100%":{transform:"rotate(360deg)"}},"@keyframes circular-dash":{"0%":{strokeDasharray:"1px, 200px",strokeDashoffset:"0px"},"50%":{strokeDasharray:"100px, 200px",strokeDashoffset:"-15px"},"100%":{strokeDasharray:"100px, 200px",strokeDashoffset:"-125px"}},circleDisableShrink:{animation:"none"}}}),{name:"MuiCircularProgress",flip:!1})(d)},565:function(e,t,r){"use strict";r.r(t),r.d(t,{__N_SSG:function(){return u},default:function(){return f}});var i=r(318),a=r(7294),n=r(5567),s=r(7978),o=r(4651),c=r(1749),l=r(5477),d=r(5893),u=!0;function f(e){var t=e.templates,r=(0,o.useRouter)(),u=a.useState(),f=(0,i.Z)(u,2),m=f[0],h=f[1],k=r.query.catId;return a.useEffect((function(){setTimeout((function(){var e,t=(null!==(e=r.query.catId)&&void 0!==e?e:"all").toString();h(t)}),1e3)}),[]),(0,d.jsxs)("div",{children:[(0,d.jsx)(s.Z,{}),!m&&(0,d.jsx)(c.Z,{container:!0,direction:"column",justifyContent:"center",alignItems:"center",style:{minHeight:"40vh"},children:(0,d.jsx)(c.Z,{item:!0,children:(0,d.jsx)(l.Z,{size:"1.5rem",thickness:8})})}),m&&(0,d.jsx)(n.Z,{templates:t,limit:!1,selectedCatId:k})]})}},3518:function(e,t,r){(window.__NEXT_P=window.__NEXT_P||[]).push(["/templates",function(){return r(565)}])}},function(e){e.O(0,[749,982,774,888,179],(function(){return t=3518,e(e.s=t);var t}));var t=e.O();_N_E=t}]);