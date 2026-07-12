from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken

from core.throttling import AuthRateThrottle
from .governorates import GOVERNORATES
from .models import Address, User
from .serializers import (
    AddressSerializer,
    UserSerializer,
    RegisterSerializer,
    LoginSerializer,
    UserUpdateSerializer,
    PasswordChangeSerializer,
)


class GovernoratesView(APIView):
    """Static list of Egypt's 27 governorates with English + Arabic
    labels. Public — every sign-up form (mobile + dashboard) hydrates
    its governorate dropdown from this endpoint, which keeps the list
    in one place even if it changes."""

    permission_classes = [AllowAny]

    def get(self, request):
        return Response(GOVERNORATES)


def get_tokens(user):
    """
    Helper function: generates JWT access + refresh tokens for a user.
    Called after register and login.
    """
    refresh = RefreshToken.for_user(user)
    return {
        "access":  str(refresh.access_token),
        "refresh": str(refresh),
    }


class RegisterView(APIView):

    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    def get(self, request):
        return Response({"message": "Use POST to register"})

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {
                    "message": "Account created successfully.",
                    "user": UserSerializer(user, context={"request": request}).data,
                    "tokens": get_tokens(user),
                },
                status=status.HTTP_201_CREATED,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):

    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data["user"]
            return Response(
                {
                    "message": "Login successful.",
                    "user": UserSerializer(user, context={"request": request}).data,
                    "tokens": get_tokens(user),
                }
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MyProfileView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(
            UserSerializer(request.user, context={"request": request}).data
        )

    def patch(self, request):
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        if serializer.is_valid():
            serializer.save()
            return Response(
                UserSerializer(request.user, context={"request": request}).data
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PasswordChangeView(APIView):
    """PUT /api/auth/password/ — change the current user's password."""

    permission_classes = [IsAuthenticated]
    throttle_classes = [AuthRateThrottle]

    def put(self, request):
        serializer = PasswordChangeSerializer(
            data=request.data, context={"request": request}
        )
        if serializer.is_valid():
            serializer.save()
            user = request.user
            return Response({
                "message": "Password updated.",
                "tokens": get_tokens(user),  # rotate tokens after password change
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LogoutView(APIView):
    """POST /api/auth/logout/ — blacklist the supplied refresh token (if blacklist app is on)."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh = request.data.get("refresh")
        if not refresh:
            return Response(
                {"error": "Provide 'refresh' token to invalidate."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            RefreshToken(refresh).blacklist()
        except Exception:
            # Blacklist app may not be installed — best effort.
            pass
        return Response({"message": "Logged out."})


class AddressListCreateView(APIView):
    """GET /api/addresses/ — list current user's addresses.
    POST /api/addresses/ — add a new address."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        addresses = Address.objects.filter(user=request.user).order_by("-is_default", "id")
        return Response(AddressSerializer(addresses, many=True).data)

    def post(self, request):
        serializer = AddressSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class AddressDeleteView(APIView):
    """DELETE /api/addresses/<id>/ — delete one of the current user's addresses."""

    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            addr = Address.objects.get(pk=pk, user=request.user)
        except Address.DoesNotExist:
            return Response({"error": "Address not found."}, status=status.HTTP_404_NOT_FOUND)
        addr.delete()
        return Response({"message": "Address deleted."}, status=status.HTTP_204_NO_CONTENT)
