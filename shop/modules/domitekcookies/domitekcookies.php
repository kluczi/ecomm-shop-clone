<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class DomitekCookies extends Module
{
    public function __construct()
    {
        $this->name = 'domitekcookies';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Domitek';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Domitek Cookie Banner');
        $this->description = $this->l('Wyświetla pasek informacyjny o plikach cookies w sklepie Domitek.');
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => _PS_VERSION_];
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayBeforeBodyClosingTag')
            && $this->registerHook('displayHeader');
    }

    public function uninstall()
    {
        return parent::uninstall();
    }

    public function hookDisplayBeforeBodyClosingTag($params)
    {
        $cmsLink = $this->context->link->getCMSLink(2); // ID 2: Polityka prywatnosci
        $this->context->smarty->assign([
            'domitek_privacy_link' => $cmsLink,
        ]);

        return $this->display(__FILE__, 'views/templates/hook/banner.tpl');
    }
}

