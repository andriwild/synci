import {FC} from "react";
import {Image, Layout, Menu, Space, theme} from "antd";
import {useNavigate} from "react-router-dom";
import {MenuInfo} from "rc-menu/lib/interface";
import {UserProfile} from "./UserProfile.tsx";

export const Header: FC = () => {
    const navigate = useNavigate();

    const items = [

        {
            key: '1',
            label: 'Sportarten',
            path: '/sport',
        },
        {
            key: '2',
            label: 'Meine Kalender',
            path: '/config',
        },
        {
            key: '3',
            label: 'Wie funktionierts?',
            path: '/faq',
        }
    ];

    const handleMenuClick = (e: MenuInfo) => {
        const clickedItem = items.find(item => item.key === e.key);
        if (clickedItem && clickedItem.path) {
            navigate(clickedItem.path);
        }
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
                onClick={ () => {
                        navigate('/');
                }
                }
            />
            <Menu
                mode="horizontal"
                defaultSelectedKeys={ ['1'] }
                items={ items }
                onClick={ handleMenuClick }
                style={{ flex: 1, minWidth: 0, backgroundColor: 'white' }}

            />
            </Space>
            <UserProfile />
        </Layout.Header>
    );
};
