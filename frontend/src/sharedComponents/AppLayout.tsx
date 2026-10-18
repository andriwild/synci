import {Layout} from "antd";
import {PreHeader} from "./PreHeader.tsx";
import {FC} from "react";
import {Header} from "./Header.tsx";
import {Content} from "antd/es/layout/layout";
import {Footer} from "./Footer.tsx";
import {Outlet} from "react-router-dom";

/**
 * App shell: pre-header, header, page content, footer. The document (body) is the only scroller;
 * pages must not set their own height/overflow. The footer sticks to the bottom via flex.
 */
export const AppLayout: FC = () => (
    <Layout className="app-layout">
        <PreHeader/>
        <Header/>
        <Content className="app-content">
            <Outlet/>
        </Content>
        <Footer/>
    </Layout>
);
