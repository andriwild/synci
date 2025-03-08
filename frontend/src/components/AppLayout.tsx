// Define a layout wrapper
import {Layout} from "antd";
import {PreHeader} from "./PreHeader.tsx";
import {FC} from "react";
import {Header} from "./Header.tsx";
import {Content} from "antd/es/layout/layout";
import {Footer} from "./Footer.tsx";
import {Outlet} from "react-router-dom";

export const AppLayout: FC = () => (
    <Layout style={{ height: '100vh', background: '#EBF0F6' }}>
        <PreHeader />
        <Header />
        <Content style={{ borderRadius: 20, background: 'white', margin: '20px' }}>
            <Outlet /> {/* This renders the child routes */}
        </Content>
        <Footer />
    </Layout>
);