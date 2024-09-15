import { Menu, Layout } from "antd";
import { useNavigate } from "react-router-dom";

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
            label: 'Konfigurationen',
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
        <Layout.Header>
            <div className="demo-logo" />
            <Menu
                theme="dark"
                mode="horizontal"
                defaultSelectedKeys={['1']}
                items={items}
                onClick={handleMenuClick}
                style={{ flex: 1, minWidth: 0 }}
            />
        </Layout.Header>
    );
};
