(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[832],{53442:function(e,t,n){"use strict";var r=n(80318),i=n(8920),o=n(282),c=n(41749),l=n(95477),s=n(67466),a=n(97133),d=n(20640),u=n.n(d),h=n(67294),p=n(42273),m=n(26671),x=n(85893);t.Z=function(e){var t=(0,h.useState)(""),n=t[0],d=t[1],v="dark"===(0,i.Z)().palette.type,f=h.useState(!1),g=(0,r.Z)(f,2),j=g[0],y=g[1];return(0,h.useEffect)((function(){fetch(e.url).then((function(e){return e.text()})).then((function(e){d(e)}))}),[e.url]),(0,x.jsxs)("div",{children:[(0,x.jsxs)("div",{style:{position:"relative"},children:[(0,x.jsx)(p.Z,{language:"dart",style:v?m.cL:m.bW,showLineNumbers:!1,customStyle:{maxHeight:"".concat(e.height),fontSize:"0.95rem"},children:n}),(0,x.jsxs)(o.Z,{"aria-label":"Copy",size:"medium",variant:"contained",color:"secondary",disableElevation:!0,style:{position:"absolute",top:"16px",right:"20px"},onClick:function(){u()(n),y(!0)},children:[(0,x.jsx)(a.Z,{fontSize:"small",style:{marginBottom:"-2px",marginRight:"2px"}}),"Copy"]})]}),!n&&(0,x.jsx)(c.Z,{container:!0,direction:"column",justifyContent:"center",alignItems:"center",style:{minHeight:"40vh"},children:(0,x.jsx)(c.Z,{item:!0,children:(0,x.jsx)(l.Z,{size:"1.5rem",thickness:8,color:"secondary"})})}),(0,x.jsx)(s.Z,{anchorOrigin:{vertical:"bottom",horizontal:"left"},open:j,autoHideDuration:4e3,onClose:function(e,t){y(!1)},message:"Code copied successfully!"})]})}},7809:function(e,t,n){"use strict";n.d(t,{Z:function(){return l}});var r=n(45051),i=n(34651),o=n(9008),c=n(85893);function l(e){var t,n,l,s,a,d,u,h,p,m,x=(0,i.useRouter)();return(0,c.jsxs)(o.default,{children:[(0,c.jsx)("title",{children:null!==(t=e.title)&&void 0!==t?t:r.B}),(0,c.jsx)("meta",{name:"description",content:null!==(n=e.description)&&void 0!==n?n:r.hy}),(0,c.jsx)("meta",{name:"keywords",content:r.Ze}),(0,c.jsx)("meta",{property:"og:url",content:null!==(l=e.url)&&void 0!==l?l:"".concat(r.bl).concat(x.asPath)}),(0,c.jsx)("meta",{property:"og:type",content:"website"}),(0,c.jsx)("meta",{property:"og:title",content:null!==(s=e.title)&&void 0!==s?s:r.B}),(0,c.jsx)("meta",{property:"og:description",content:null!==(a=e.description)&&void 0!==a?a:r.hy}),(0,c.jsx)("meta",{property:"og:image",content:null!==(d=e.image)&&void 0!==d?d:r.j7}),(0,c.jsx)("meta",{name:"twitter:card",content:"summary_large_image"}),(0,c.jsx)("meta",{property:"twitter:url",content:null!==(u=e.url)&&void 0!==u?u:r.bl}),(0,c.jsx)("meta",{name:"twitter:title",content:null!==(h=e.title)&&void 0!==h?h:r.B}),(0,c.jsx)("meta",{name:"twitter:description",content:null!==(p=e.description)&&void 0!==p?p:r.hy}),(0,c.jsx)("meta",{name:"twitter:image",content:null!==(m=e.image)&&void 0!==m?m:r.j7})]})}},37847:function(e,t,n){"use strict";function r(e,t,n,r,i,o,c){try{var l=e[o](c),s=l.value}catch(a){return void n(a)}l.done?t(s):Promise.resolve(s).then(r,i)}n.r(t),n.d(t,{__N_SSG:function(){return G},default:function(){return M}});var i=n(809),o=n.n(i),c=n(7809),l=n(67294),s=n(41749),a=n(95477),d=n(8920),u=n(87462),h=n(45987),p=(n(45697),n(86010)),m=n(14670),x=n(66987),v=l.forwardRef((function(e,t){var n=e.children,r=e.classes,i=e.className,o=e.component,c=void 0===o?"ul":o,s=e.dense,a=void 0!==s&&s,d=e.disablePadding,m=void 0!==d&&d,v=e.subheader,f=(0,h.Z)(e,["children","classes","className","component","dense","disablePadding","subheader"]),g=l.useMemo((function(){return{dense:a}}),[a]);return l.createElement(x.Z.Provider,{value:g},l.createElement(c,(0,u.Z)({className:(0,p.Z)(r.root,i,a&&r.dense,!m&&r.padding,v&&r.subheader),ref:t},f),v,n))})),f=(0,m.Z)({root:{listStyle:"none",margin:0,padding:0,position:"relative"},padding:{paddingTop:8,paddingBottom:8},dense:{},subheader:{paddingTop:0}},{name:"MuiList"})(v),g=n(22318),j=n(58867),y=n(85893);var b=function(e){var t=(0,d.Z)();return(0,y.jsx)("div",{style:{width:"".concat(220,"px"),marginTop:"3rem"},children:(0,y.jsx)(f,{children:e.widgetGroups.map((function(n,r){return(0,y.jsxs)("div",{children:[(0,y.jsx)(g.Z,{style:{fontWeight:"bold"},children:n.title}),(0,y.jsx)(f,{children:n.widget_subgroups.map((function(n,r){var i,o;return(0,y.jsx)(j.Z,{button:!0,onClick:function(){return e.onSubGroupSelected(n)},style:{backgroundColor:(null===(i=e.selectedSubGroup)||void 0===i?void 0:i.title)===n.title?"".concat(t.palette.secondary.main,"10"):""},children:(0,y.jsx)(g.Z,{style:{color:(null===(o=e.selectedSubGroup)||void 0===o?void 0:o.title)===n.title?t.palette.secondary.main:""},children:n.title})},"sub_group_".concat(r))}))})]},"group_".concat(r))}))})})},Z=n(80318),w=n(17812),C=n(282),_=n(25209),k=(0,_.Z)(l.createElement("path",{d:"M16 1H8C6.34 1 5 2.34 5 4v16c0 1.66 1.34 3 3 3h8c1.66 0 3-1.34 3-3V4c0-1.66-1.34-3-3-3zm-2.5 20h-3c-.28 0-.5-.22-.5-.5s.22-.5.5-.5h3c.28 0 .5.22.5.5s-.22.5-.5.5zm3.5-3H7V4h10v14z"}),"PhoneAndroidRounded"),S=(0,_.Z)(l.createElement("path",{d:"M18 0H6C4.34 0 3 1.34 3 3v18c0 1.66 1.34 3 3 3h12c1.66 0 3-1.34 3-3V3c0-1.66-1.34-3-3-3zm-4.5 22h-3c-.28 0-.5-.22-.5-.5s.22-.5.5-.5h3c.28 0 .5.22.5.5s-.22.5-.5.5zm5.75-3H4.75V3h14.5v16z"}),"TabletAndroidRounded"),z=(0,_.Z)(l.createElement("path",{d:"M21 2H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h7l-1.63 2.45c-.44.66.03 1.55.83 1.55h5.6c.8 0 1.28-.89.83-1.55L14 18h7c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 12H3V5c0-.55.45-1 1-1h16c.55 0 1 .45 1 1v9z"}),"DesktopMacRounded"),U=n(59967),E=(0,_.Z)(l.createElement("path",{d:"M18 19H6c-.55 0-1-.45-1-1V6c0-.55.45-1 1-1h5c.55 0 1-.45 1-1s-.45-1-1-1H5c-1.11 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-6c0-.55-.45-1-1-1s-1 .45-1 1v5c0 .55-.45 1-1 1zM14 4c0 .55.45 1 1 1h2.59l-9.13 9.13c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0L19 6.41V9c0 .55.45 1 1 1s1-.45 1-1V4c0-.55-.45-1-1-1h-5c-.55 0-1 .45-1 1z"}),"OpenInNewRounded"),N=n(53442),R=[{label:"Mobile",value:"400px",icon:(0,y.jsx)(k,{})},{label:"Tablet",value:"650px",icon:(0,y.jsx)(S,{})},{label:"Desktop",value:"900px",icon:(0,y.jsx)(z,{})}];var H=function(e){var t=(0,d.Z)(),n=l.useState(R[2]),r=(0,Z.Z)(n,2),i=r[0],o=r[1],c=l.useState(0),a=(0,Z.Z)(c,2),u=a[0],h=a[1];return(0,y.jsx)("div",{children:(0,y.jsxs)(s.Z,{spacing:2,container:!0,direction:"column",style:{borderRadius:"10px"},children:[(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)("div",{style:{border:"1px solid #cccccc50",borderRadius:"0.5rem",padding:"1rem"},children:(0,y.jsxs)(s.Z,{container:!0,direction:"row",justifyContent:"center",alignItems:"center",style:{height:"100%"},children:[(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)(g.Z,{variant:"h6",style:{fontWeight:"bold"},children:e.title})}),(0,y.jsx)(s.Z,{item:!0,style:{display:"flex",flexGrow:1,flexDirection:"row",justifyContent:"center"},children:0==u?(0,y.jsx)(y.Fragment,{children:R.map((function(e){return(0,y.jsx)(w.Z,{"area-label":e.label,size:"small",style:{color:"".concat(e.value===i.value?"white":t.palette.secondary.main),backgroundColor:"".concat(e.value===i.value?t.palette.secondary.main:"".concat(t.palette.secondary.main,"10")),padding:"6px",borderRadius:"4px",marginRight:"0.5rem"},onClick:function(){o(e)},children:e.icon})}))}):(0,y.jsx)("div",{children:" "})}),[0,1].map((function(e){return(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)(C.Z,{style:{textTransform:"capitalize",color:"".concat(u==e?"white":""),backgroundColor:"".concat(u==e?"".concat(t.palette.secondary.main):"")},onClick:function(){h(e)},children:0===e?"Demo":"Code"})})})),(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)("a",{href:e.codeUrl,target:"_blank",rel:"noopener noreferrer",children:(0,y.jsx)(w.Z,{children:(0,y.jsx)(U.Z,{})})})}),(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)("a",{href:e.demoUrl,target:"_blank",rel:"noopener noreferrer",children:(0,y.jsx)(w.Z,{children:(0,y.jsx)(E,{})})})})]})})}),(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)("div",{style:{display:"flex",flexDirection:"row",justifyContent:"center",height:"70vh"},children:function(n){return 0==n?(0,y.jsx)("div",{style:{height:"100%",width:"100%",display:"flex",justifyContent:"center",borderRadius:"0.5rem",padding:"1rem",backgroundColor:t.palette.background.paper},children:(0,y.jsx)("iframe",{src:e.demoUrl,style:{backgroundColor:t.palette.background.paper,maxWidth:i.value,height:"100%",width:"100%",border:"none"}})}):(0,y.jsx)("div",{style:{width:"100%"},children:(0,y.jsx)(N.Z,{url:e.rawCodeUrl,height:"70vh"})})}(u)})})]})})};var D=function(e){return(0,y.jsxs)("div",{style:{width:"100%",marginTop:"1rem",marginLeft:"1rem"},children:[(0,y.jsx)(g.Z,{variant:"h4",style:{fontWeight:"bold"},children:e.componentSubgroup.title}),(0,y.jsx)(f,{children:e.componentSubgroup.widgets.map((function(e,t){return(0,y.jsx)(H,{title:e.title,codeUrl:e.codeUrl,demoUrl:e.demoUrl,rawCodeUrl:e.rawCodeUrl},"widget_".concat(t,"_").concat(e.title))}))})]})},G=!0;function M(e){e.postData;var t,n=e.allDocsNestedData,i=(0,l.useState)(!0),d=i[0],u=i[1],h=(0,l.useState)(),p=h[0],m=h[1],x=(0,l.useState)(),v=x[0],f=x[1];return(0,l.useEffect)((function(){(function(){var e,t=(e=o().mark((function e(){var t,r;return o().wrap((function(e){for(;;)switch(e.prev=e.next){case 0:t=[],n.files.map((function(e){var n=[];e.files.map((function(e){var t=[];e.files.map((function(e){t.push({title:e.matter.title,demoUrl:e.matter.demoUrl,codeUrl:e.matter.codeUrl,rawCodeUrl:e.matter.rawCodeUrl})}));var r={title:e.matter.title,widgets:t};n.push(r)}));var r={title:e.matter.title,widget_subgroups:n};t.push(r)})),m(r={widget_groups:t}),f(r.widget_groups[0].widget_subgroups[0]),u(!1);case 6:case"end":return e.stop()}}),e)})),function(){var t=this,n=arguments;return new Promise((function(i,o){var c=e.apply(t,n);function l(e){r(c,i,o,l,s,"next",e)}function s(e){r(c,i,o,l,s,"throw",e)}l(void 0)}))});return function(){return t.apply(this,arguments)}})()()}),[n]),(0,y.jsxs)(y.Fragment,{children:[(0,y.jsx)(c.Z,{title:"Browse production ready Flutter UI Components"}),d?(0,y.jsx)(s.Z,{container:!0,alignContent:"center",style:{display:"flex",justifyContent:"center",height:"80vh"},children:(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)(a.Z,{size:"1.5rem",thickness:8,color:"secondary"})})}):(0,y.jsxs)(s.Z,{container:!0,direction:"row",justifyContent:"center",children:[(0,y.jsx)(s.Z,{item:!0,children:(0,y.jsx)(b,{selectedSubGroup:v,onSubGroupSelected:function(e){f(e)},widgetGroups:null!==(t=null===p||void 0===p?void 0:p.widget_groups)&&void 0!==t?t:[]})}),(0,y.jsx)(s.Z,{item:!0,xs:12,md:8,lg:8,children:v?(0,y.jsx)(D,{componentSubgroup:v}):(0,y.jsx)("div",{})})]})]})}},48113:function(e,t,n){(window.__NEXT_P=window.__NEXT_P||[]).push(["/widgets/[[...id]]",function(){return n(37847)}])}},function(e){e.O(0,[282,774,888,179],(function(){return t=48113,e(e.s=t);var t}));var t=e.O();_N_E=t}]);