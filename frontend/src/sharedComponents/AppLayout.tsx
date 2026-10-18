import {Layout} from "antd";
import {PreHeader} from "./PreHeader.tsx";
import {FC} from "react";
import {Header} from "./Header.tsx";
import {Content} from "antd/es/layout/layout";
import {Footer} from "./Footer.tsx";
import {Outlet, useMatch} from "react-router-dom";

/**
 * App shell: pre-header, header, page content, footer. By default the document (body) is the only
 * scroller and the footer sticks to the bottom via flex. Pages listed in useFitsViewport() fill exactly
 * the viewport from tablet up instead: header and footer stay visible and the page scrolls internally.
 */
export const AppLayout: FC = () => {
    const fitsViewport = useFitsViewport();
    return (
        <Layout className={`app-layout ${fitsViewport ? "app-layout--fit" : ""}`}>
            <PreHeader/>
            <Header/>
            <Content className="app-content">
                <Outlet/>
            </Content>
            <Footer/>
        </Layout>
    );
};

/** the sport column tree scrolls per column, the page itself never scrolls */
const useFitsViewport = () => !!useMatch("/sport");
