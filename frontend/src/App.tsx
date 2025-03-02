import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider, theme } from "antd";
import { UserConfigsPage } from "./pages/calender/UserConfigsPage.tsx";
import { UserConfigForm } from "./pages/calender/UserConfigForm.tsx";
import { HomePage } from "./pages/home/HomePage.tsx";
import { FC } from 'react';

import {SportPage} from "./pages/sport/SportPage.tsx";
import './index.css';
import {LoginPage} from "./pages/login/LoginPage.tsx";
import {AppLayout} from "./components/AppLayout.tsx";

export const App: FC = () => {
    return (
        <Router>
            <ConfigProvider
                theme={{
                    algorithm: theme.defaultAlgorithm,
                    token: {
                        colorPrimary: '#3D5A80',
                        colorHighlight: '#FFEE77',
                        borderRadius: 20,
                        colorBgContainer: '#EBF0F6',
                    },
                }}
            >
                <Routes>
                    {/* No Layout for Login */}
                    <Route path="/login" element={<LoginPage />} />

                    {/* Apply Layout to all other routes */}
                    <Route element={<AppLayout/>}>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/sport" element={<SportPage />} />
                        <Route path="/config" element={<UserConfigsPage />} />
                        <Route path="/config/:id" element={<UserConfigForm />} />
                    </Route>
                </Routes>
            </ConfigProvider>
        </Router>
    );
}

export default App;
