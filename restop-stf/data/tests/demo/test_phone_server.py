# __author__ = 'cocoon'
#
#
#
# from restop.application import get_application, start
#
# #from backend.native_backend import NativeBackend as Backend
# from backend.redis_backend import RedisBackend as Backend
#
#
# from restop.collection import GenericCollectionWithOperationApi
#
#
# from devices.session_server.ptf_manager2 import SypConfiguration
#
#
# # import resources
# import  devices.session_server.server_resources
#
#
#
# #
# # create flask app
# #
#
# # get a flask application
# app = get_application(__name__,with_error_handler=True)
#
# app.config.from_pyfile('config.cfg')
#
# backend= Backend("",app.config['WORKSPACE_ROOT'],spec_base= app.config["SPEC_ROOT"],config=app.config)
#
# # for debug
# backend.db.flushdb()
#
# app.config['backend'] = backend
#
#
# #
# # update backend with platform info
# #
# conf= SypConfiguration.from_file(app.config['PHONEHUB_PLATFORM'])
# ptf=  conf.get_ptf(app.config['PHONEHUB_PLATFORM_VERSION'])
#
# rc= ptf.update_backend(backend)
#
#
# #
# # create collection blueprint
# #
# blueprint_name='restop_agents'
# url_prefix= '/restop/api/v1'
# collections= [ "root", "oauth2","files","agents","pjterm_agents","droyd_agents","phone_sessions",
#                'syp_agents','droyd_phone_agents','syprunner_agents','droydrunner_agents']
#
# app.config['collections']= {}
# app.config['collections'][blueprint_name]= collections
#
# my_blueprint= GenericCollectionWithOperationApi.create_blueprint(blueprint_name,__name__,url_prefix='/restop/api/v1',
#                 collections= collections)
# app.register_blueprint(my_blueprint,url_prefix='')
#



# @app.route('/')
# def index():
#     """
#
#     :return:
#     """
#     return "hello from restop server: try /restop/api/v1"



from devices.session_server.phone_server import start_server


start_server()



