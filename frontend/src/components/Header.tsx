import {FC} from "react";
import {Image, Layout, Menu, Space, theme} from "antd";
import {useLocation, useNavigate} from "react-router-dom";
import {CalendarBlank, ListBullets, QuestionMark} from "@phosphor-icons/react";
import {UserProfile} from "./UserProfile.tsx";

export const Header: FC = () => {
    const navigate = useNavigate();
    const location =useLocation();

    const items = [
        {
            key: '1',
            label: <span>Sportarten</span>,
            icon: <ListBullets />,
            path: '/sport'
        },
        {
            key: '2',
            label: <span>Meine Kalender</span>,
            icon: <CalendarBlank />,
            path: '/config'
        },
        {
            key: '3',
            label: <span>Wie funktionierts?</span>,
            icon: <QuestionMark />,
            path: '/faq'
        }
    ];

    const handleMenuClick = (e: any) => {
        navigate(e.path);
    };


    const { token } = theme.useToken();
    return (
        <Layout.Header style={{ display: 'flex', alignItems: 'center', justifyContent:'space-between', padding: ' 0 24px', backgroundColor: 'white', margin:'20px 20px 0px 20px', borderRadius:  token.borderRadius }}>
           <Space>
            <Image
                src={ './assets/Logo_synci.png' }
                preview={ false }
                style={{
                    cursor: 'pointer',
                    padding: '10px 20px 10px 0',
                    maxHeight: 60 }}
                onClick={() => {
                    navigate('/');
                }
                }
            />
            <Menu
                mode="horizontal"
                items={ items }
                style={{ flex: 1, minWidth: 0, backgroundColor: 'white' }}
                onClick={handleMenuClick}
                selectedKeys={[location.pathname]}
            />
            </Space>
            <UserProfile />
        </Layout.Header>
    );
};
