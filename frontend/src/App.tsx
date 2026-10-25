import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider, theme } from "antd";
import { HomePage } from "./pages/home/HomePage.tsx";
import {useEffect} from 'react';

import {SportPage} from "./pages/sport/SportPage.tsx";
import './index.css';
import {AppLayout} from "./sharedComponents/AppLayout.tsx";
import {FaqPage} from "./pages/faq/FaqPage.tsx";
import {DatenschutzPage} from "./pages/datenschutz/DatenschutzPage.tsx";
import {SyncConfigPage} from "./pages/syncConfig/SyncConfigPage.tsx";
import {OrganisationsPage} from "./pages/organisation/OrganisationsPage.tsx";
import {OrganisationMembersPage} from "./pages/organisation/OrganisationMembersPage.tsx";
import {useAuth0} from "@auth0/auth0-react";
import {useAppDispatch} from "./app/hooks.ts";
import {userActions, useUser} from "./services/user/UserSlice.ts";
import {setAuth0Client} from "./services/common/apiHelpers.ts";
import {ImpressumPage} from "./pages/impressum/ImpressumPage.tsx";
import {AnswerPage} from "./pages/answer/AnswerPage.tsx";
import {userApi} from "./services/user/userApi.ts";

export const App = () => {
    const { user, isAuthenticated, getAccessTokenSilently, loginWithRedirect } = useAuth0();
    const dispatch = useAppDispatch();
    const storedUser = useUser();

    // the backend only knows the Auth0 subject; report email and name for organisation member lists
    useEffect(() => {
        if (storedUser?.email) {
            const name = [storedUser.firstName, storedUser.lastName].filter(Boolean).join(" ") || undefined;
            dispatch(userApi.endpoints.updateMe.initiate({email: storedUser.email, name}));
        }
    }, [storedUser?.email, storedUser?.firstName, storedUser?.lastName, dispatch]);

    useEffect(() => {
        setAuth0Client({ getTokenSilently: getAccessTokenSilently, loginWithRedirect });
    }, [getAccessTokenSilently, loginWithRedirect]);

    useEffect(() => {
        const fetchAndStoreToken = async () => {
            if (isAuthenticated) {
                try {
                    await getAccessTokenSilently();
                    dispatch(userActions.setUser({
                        firstName: user?.given_name || '',
                        lastName: user?.family_name || '',
                        email: user?.email || '',
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
                        <Route path="/organisationen" element={<OrganisationsPage/>} />
                        <Route path="/organisationen/:id/mitglieder" element={<OrganisationMembersPage/>} />
                        <Route path="/faq" element={<FaqPage />} />
                        <Route path="/impressum" element={<ImpressumPage />} />
                        <Route path="/datenschutz" element={<DatenschutzPage />} />
                        <Route path="/antwort/:configId/:eventId" element={<AnswerPage/>} />
                    </Route>
                </Routes>
            </ConfigProvider>
        </Router>
    );
}

export default App;
