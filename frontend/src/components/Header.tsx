import {Layout, Menu} from "antd";
import {useNavigate} from "react-router-dom";
import {CalendarCheck} from "@phosphor-icons/react";

export const Header = () => {
    const navigate = useNavigate();

    const items = [
        {
            key: '1',
            label: 'Home',
            path: '/',
        },
        {
            key: '2',
            label: 'Meine Abos',
            path: '/config',
        }
    ];

    const handleMenuClick = (e: any) => {
        const clickedItem = items.find(item => item.key === e.key);
        if (clickedItem && clickedItem.path) {
            navigate(clickedItem.path);
        }
    };

    return (
        <Layout.Header style={{ display: 'flex', alignItems: 'center', padding: '0  24px', backgroundColor: '#eaeaea  ' }}>
            <CalendarCheck size={32} style={{color: "black", marginRight: 16}}/>
            <Menu
                mode="horizontal"
                defaultSelectedKeys={['1']}
                items={items}
                onClick={handleMenuClick}
                style={{ flex: 1, minWidth: 0 }}
            />
        </Layout.Header>
    );
};
