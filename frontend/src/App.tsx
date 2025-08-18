import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider, theme } from "antd";
import { HomePage } from "./pages/home/HomePage.tsx";
import {useEffect} from 'react';

import {SportPage} from "./pages/sport/SportPage.tsx";
import './index.css';
import {AppLayout} from "./sharedComponents/AppLayout.tsx";
import {FaqPage} from "./pages/faq/FaqPage.tsx";
import {SyncConfigPage} from "./pages/syncConfig/SyncConfigPage.tsx";
import {useAuth0} from "@auth0/auth0-react";
import {useAppDispatch} from "./app/hooks.ts";
import {userActions} from "./services/user/UserSlice.ts";
import {setAuth0Client, setStoreHelpers} from "./services/common/apiHelpers.ts";

export const App = () => {
    const { user, isAuthenticated, getAccessTokenSilently, loginWithRedirect } = useAuth0();
    const dispatch = useAppDispatch();

    useEffect(() => {
        setAuth0Client({ getTokenSilently: getAccessTokenSilently, loginWithRedirect });
        setStoreHelpers(dispatch, userActions);
    }, [getAccessTokenSilently, loginWithRedirect, dispatch]);

    useEffect(() => {
        const fetchAndStoreToken = async () => {
            if (isAuthenticated) {
                try {
                    const token = await getAccessTokenSilently();
                    dispatch(userActions.setUser({
                        id: user?.sub || '',
                        name: user?.name || '',
                        email: user?.email || '',
                        token: token,
                        picture: user?.picture || '',
                    }
                    ));
                } catch (e) {
                    console.error("Token konnte nicht geladen werden", e);
                }
            }
        };

        fetchAndStoreToken();
    }, [isAuthenticated, user, getAccessTokenSilently, dispatch]);

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
                        fontFamily: "'Montserrat', system-ui, Avenir, Helvetica, Arial, sans-serif",
                    },
                    components: {
                        Button: {
                            colorPrimary: '#3D5A80',
                            borderRadius: 8,
                        },
                    },
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
