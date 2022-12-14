class Chatgpt::Chrome < Selenium::WebDriver::Chrome::Driver
  def initialize(bridge: nil, listener: nil, options: nil, **opts)
    if options.blank?
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--no-sandbox')
      options.add_argument('--window-size=1920,1080')
      options.add_argument('--no-default-browser-check')
      options.add_argument('--no-first-run')
      options.add_argument('--enable-javascript')
      options.add_argument('--start-maximized')
      options.add_argument('--test-type')
      options.add_option('excludeSwitches', ['enable-automation'])
      options.add_argument('--disable-blink-features=AutomationControlled')
    end
    super(options: options, **opts)
  end

  def get(url)
    execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: "
                        Object.defineProperty(window, 'navigator', {
                            value: new Proxy(navigator, {
                                    has: (target, key) => (key === 'webdriver' ? false : key in target),
                                    get: (target, key) =>
                                            key === 'webdriver' ?
                                            undefined :
                                            typeof target[key] === 'function' ?
                                            target[key].bind(target) :
                                            target[key]
                                    })
                        });
                ")
    ua = execute_script('return navigator.userAgent')
    execute_cdp('Network.setUserAgentOverride', userAgent: ua.gsub('Headless', ''))
    execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: "Object.defineProperty(navigator, 'maxTouchPoints', {get: () => 1});
                        Object.defineProperty(navigator.connection, 'rtt', {get: () => 100});
                        window.chrome = {
                            app: {
                                isInstalled: false,
                                InstallState: {
                                    DISABLED: 'disabled',
                                    INSTALLED: 'installed',
                                    NOT_INSTALLED: 'not_installed'
                                },
                                RunningState: {
                                    CANNOT_RUN: 'cannot_run',
                                    READY_TO_RUN: 'ready_to_run',
                                    RUNNING: 'running'
                                }
                            },
                            runtime: {
                                OnInstalledReason: {
                                    CHROME_UPDATE: 'chrome_update',
                                    INSTALL: 'install',
                                    SHARED_MODULE_UPDATE: 'shared_module_update',
                                    UPDATE: 'update'
                                },
                                OnRestartRequiredReason: {
                                    APP_UPDATE: 'app_update',
                                    OS_UPDATE: 'os_update',
                                    PERIODIC: 'periodic'
                                },
                                PlatformArch: {
                                    ARM: 'arm',
                                    ARM64: 'arm64',
                                    MIPS: 'mips',
                                    MIPS64: 'mips64',
                                    X86_32: 'x86-32',
                                    X86_64: 'x86-64'
                                },
                                PlatformNaclArch: {
                                    ARM: 'arm',
                                    MIPS: 'mips',
                                    MIPS64: 'mips64',
                                    X86_32: 'x86-32',
                                    X86_64: 'x86-64'
                                },
                                PlatformOs: {
                                    ANDROID: 'android',
                                    CROS: 'cros',
                                    LINUX: 'linux',
                                    MAC: 'mac',
                                    OPENBSD: 'openbsd',
                                    WIN: 'win'
                                },
                                RequestUpdateCheckStatus: {
                                    NO_UPDATE: 'no_update',
                                    THROTTLED: 'throttled',
                                    UPDATE_AVAILABLE: 'update_available'
                                }
                            }
                        }
                        if (!window.Notification) {
                            window.Notification = {
                                permission: 'denied'
                            }
                        }
                        const originalQuery = window.navigator.permissions.query
                        window.navigator.permissions.__proto__.query = parameters =>
                            parameters.name === 'notifications'
                                ? Promise.resolve({ state: window.Notification.permission })
                                : originalQuery(parameters)
                        const oldCall = Function.prototype.call
                        function call() {
                            return oldCall.apply(this, arguments)
                        }
                        Function.prototype.call = call
                        const nativeToStringFunctionString = Error.toString().replace(/Error/g, 'toString')
                        const oldToString = Function.prototype.toString
                        function functionToString() {
                            if (this === window.navigator.permissions.query) {
                                return 'function query() { [native code] }'
                            }
                            if (this === functionToString) {
                                return nativeToStringFunctionString
                            }
                            return oldCall.call(oldToString, this)
                        }
                        Function.prototype.toString = functionToString
                        ")
    result = execute_script("
        let objectToInspect = window,
            result = [];
        while(objectToInspect !== null)
        { result = result.concat(Object.getOwnPropertyNames(objectToInspect));
            objectToInspect = Object.getPrototypeOf(objectToInspect); }
        return result.filter(i => i.match(/.+_.+_(Array|Promise|Symbol)/ig))")

    if result.length > 0
      execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: "
                            let objectToInspect = window,
                                result = [];
                            while(objectToInspect !== null)
                            { result = result.concat(Object.getOwnPropertyNames(objectToInspect));
                            objectToInspect = Object.getPrototypeOf(objectToInspect); }
                            result.forEach(p => p.match(/.+_.+_(Array|Promise|Symbol)/ig)
                                                &&delete window[p]&&console.log('removed',p))
            ")
    end
    super
  end

  def execute_cdp(cmd, **params)
    @bridge.send_command(cmd: cmd, params: params)
  end
end
