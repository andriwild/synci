import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider, Layout, theme } from "antd";
import { UserConfigsPage } from "./pages/calender/UserConfigsPage.tsx";
import { UserConfigForm } from "./pages/calender/UserConfigForm.tsx";
import { Header } from "./components/Header.tsx";
import { Footer } from "./components/Footer.tsx";
import { Content } from "antd/es/layout/layout";
import { HomePage } from "./pages/home/HomePage.tsx";
import { FC } from 'react';
import {PreHeader} from "./components/PreHeader.tsx";
import {SportPage} from "./pages/sport/SportPage.tsx";
import './index.css';

export const App: FC = () => {

    return (
        <Router>
            <ConfigProvider
                theme={{
                    algorithm: theme.defaultAlgorithm,
                    token: {
                        colorPrimary: '#3D5A80',
                        borderRadius: 20,
                        colorBgContainer: '#EBF0F6',
                    },
                }}
            >
            <Layout style={{height: '100vh',background: '#EBF0F6'}}>
                <PreHeader />
                <Header />
                <Content style={{ borderRadius: 20, background: 'white', margin: '20px'}}>
                    <Routes>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/sport" element={<SportPage />} />
                        <Route path="/config/" element={<UserConfigsPage />} />
                        <Route path="/config/:id" element={<UserConfigForm />} />
                    </Routes>
                </Content>
                <Footer />
            </Layout>
            </ConfigProvider>
        </Router>
    );
}

export default App;
