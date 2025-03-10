import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider, theme } from "antd";
import { HomePage } from "./pages/home/HomePage.tsx";
import { FC } from 'react';

import {SportPage} from "./pages/sport/SportPage.tsx";
import './index.css';
import {AppLayout} from "./components/AppLayout.tsx";
import {FaqPage} from "./pages/faq/FaqPage.tsx";
import {SyncConfigPage} from "./pages/syncConfig/SyncConfigPage.tsx";

export const App: FC = () => {

    return (
        <Router>
            <ConfigProvider
                theme={{
                    algorithm: theme.defaultAlgorithm,
                    token: {
                        colorPrimary: '#3D5A80',
                        colorTextSecondary: '#C5CDD9',
                        colorHighlight: '#FFEE77',
                        borderRadius: 20,
                        colorBgContainer: '#EBF0F6',
                        colorBgBase: '#F4F4F4',
                    }
                }}
            >
                <Routes>
                    {/* No Layout for Login */}

                    {/* Apply Layout to all other routes */}
                    <Route element={<AppLayout/>}>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/sport" element={<SportPage />} />
                        <Route path="/syncConfig" element={<SyncConfigPage/>} />
                        <Route path="/faq" element={<FaqPage />} />
                    </Route>
                </Routes>
            </ConfigProvider>
        </Router>
    );
}

export default App;
